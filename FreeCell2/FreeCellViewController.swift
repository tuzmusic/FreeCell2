//
//  ViewController.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class FreeCellViewController: UIViewController {
	
	// MARK: Model
	var game = FreeCellBrain()
	
	var startOfSelection: Position? {
		
		didSet {		// Select or deselect PlayingCardViews
			if let start = startOfSelection ?? oldValue {
				for view in boardView.subviews where view is PlayingCardView {
					let cardView = view as! PlayingCardView
					if cardView.position.column == start.column && cardView.position.row >= start.row {
						cardView.isSelected = (startOfSelection != nil ? true : false)
					}
				}
			}
		}
	}
	
	var selectedCard: FreeCellBrain.Card? {
		if let selection = startOfSelection {
			return game.cardAt(selection)
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			if game.locationFor(column: selection.column) == Location.cardColumns {
				let length = game.board[selection.column].count - selection.row
				return length
			}
			return 1
		}
		return nil
	}
	
	var lastClickedView: UIView?
	var lastClickedCard: FreeCellBrain.Card? {
		if let description = (lastClickedView as? PlayingCardView)?.cardDescription {
			return game.cardWith(description: description)
		}
		return nil
	}
	var lastClickedPosition: Position? {
		if let description = (lastClickedView as? PlayingCardView)?.cardDescription {
			return game.positionForCardWith(description: description)
		}
		return nil
	}
	
	var clickedColumn: FreeCellBrain.Column? {
		if let position = lastClickedPosition {
			return game.board[position.column]
		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func restartGame(_ sender: UIButton) {
		//boardView.gravityFalls()
		startGame()
	}
	@IBOutlet weak var restartButton: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func moveCardViewWith(description: String, to dest: Position, in location: Int) {
			if let view = boardView.subviews.first(where: { ($0 as? PlayingCardView)?.cardDescription == description }) {
				UIView.animate(withDuration: 0.5, animations: { 
					view.frame.origin.x = self.boardView.xValueForCardIn(location: location, column: dest.column)
					view.frame.origin.y = self.boardView.yCoordinateForCardIn(location, row: dest.row + 1)
				}, completion: { (_) in
					(view as! PlayingCardView).isSelected = false
				})
				
			}
		// This is INCOMPLETE, because we're no longer drawing cards at new positions and therefore not assigning cards a position.
		// In fact, cardViews no longer need a position property.
		// But that also means, I'm pretty sure, that selecting cards will have to be handled in a totally different way.
		// Probably by asking the model for the cards that should be selected, and then selecting the cards with those descriptions.
		// Also, a lot of other stuff is fucked up. See checklist in Notes app.
	}
	
	func move(from source: Position, to dest: Position) {
		
		// we don't need the iterator number because the row is always the same
		// since each time a card is removed, the cards after it bump up their index
		for _ in 1 ... stackLength(for: source)! {
			game.moveCard(from: source, to: dest)	// Move the card in the model
			
			if let movedCard = game.board[dest.column].last {	// Move the card in the view
				
				/*   Animated: (not working correctly yet)
				moveCardViewWith(description: movedCard.description, to: dest, in: game.locationFor(column: dest.column)!)
				*/
			
				if let view = boardView.subviews.first(where: { ($0 as? PlayingCardView)?.cardDescription == movedCard.description  }) {
					view.removeFromSuperview()
				}
				let destRow = game.board[dest.column].count - 1
				let destPosition = Position(column: dest.column, row: destRow)
				draw(card: movedCard, at: destPosition)
			}
		}
		startOfSelection = nil
		postMoveCleanUp()
	}
	
	func postMoveCleanUp() { //print("cleanup")
		
		if let autoMove = game.cardToMoveToSuitStack() {
			let suitStack = Position(column: autoMove.destStackIndex, row: game.board[autoMove.destStackIndex].count-1)
			move(from: autoMove.cardOldPosition, to: suitStack)
		}
		
		if game.gameIsWon() { gameWon() }
		if game.noMovesLeft() { gameLost() }
	}
	
	func gameWon () {
		print("You won!")
	}
	
	func gameLost () {
		print("No moves left!")
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { lastClickedView = clickedCard.view
		// This should be ready to test but it wasn't a good time to test it yet.
		if let description = (clickedCard.view as? PlayingCardView)?.cardDescription {
			if let position = game.positionForCardWith(description: description) {
				// If there was no selection, or the selection was in the same column, get the new selection.
				if startOfSelection == nil
					|| position.column == startOfSelection?.column {
					let oldSelection = startOfSelection
					startOfSelection = nil // Clear the old selection
					if position.row != oldSelection?.row {
						startOfSelection = position // Unless the click was on the same card (to clear selection), get new selection.
					}
				} else if let selection = startOfSelection {
					let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
					// See if the stack can be moved, and move it.
					if (game.columnIs(in: Location.cardColumns, column: position.column)
						//						position.location == Location.cardColumns
						&& game.canMove(movingStack, toColumn: clickedColumn!))
						|| (game.columnIs(in: Location.suitStacks, column: position.column)
							//						|| (position.location == Location.suitStacks
							&& movingStack.count == 1
							&& game.canMove(selectedCard!, to: clickedColumn!)) {
						move(from: selection, to: position)
					}
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { //print("Empty column clicked!")
		if let clickedCell = cell.view as? CardView { lastClickedView = clickedCell
			if let selection = startOfSelection {
				// Create the stack to check if it can be moved
				let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
				
				// See if the stack can be moved, and move it.
				if game.canMove(movingStack, toColumn: clickedColumn!) {
					move(from: selection, to: clickedCell.position!)
				}
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) { //print("Cell clicked!")
		if let cellView = cell.view as? CardView { lastClickedView = cellView
			if stackLength(for: startOfSelection) == 1 {
				move(from: startOfSelection!, to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { //print("Suit clicked!")
		if let suitView = suit.view as? CardView { lastClickedView = suitView
			if stackLength(for: startOfSelection) == 1 && game.canMove(selectedCard!, to: clickedColumn!) {
				move(from: startOfSelection!, to: suitView.position)
			}
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			if stackLength(for: startOfSelection) == 1 {
				for (index, suit) in game.board.enumerated() where game.columnIs(in: Location.suitStacks, column: index) {
					if game.canMove(selectedCard!, to: suit) {
						let destPosition = Position(column: index, row: 0)
						move(from: clickedCardView.position, to: destPosition)
						return
					}
				}
				for (index, cell) in game.board.enumerated() where game.columnIs(in: Location.freeCells, column: index) {
					if cell.isEmpty {
						let destPosition = Position(column: index, row: 0)
						move(from: clickedCardView.position, to: destPosition)
						return
					}
				}
			}
		}
	}
	
	// MARK: Setup functions
	
	func draw (card: FreeCellBrain.Card, at boardPosition: Position) {
		
		let newCardView = PlayingCardView()
		
		var columnOffset = 0
		switch game.locationFor(column: boardPosition.column)! {
		case 1: columnOffset = 4; case 2: columnOffset = 8; default: break
		}
		
		newCardView.frame.origin.x = boardView.xValueForCardIn(location: game.locationFor(column: boardPosition.column)!,
		                                                       column: boardPosition.column - columnOffset)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(game.locationFor(column: boardPosition.column)!,
		                                                            row: boardPosition.row)
		newCardView.frame.size = boardView.cardSize
		
		newCardView.backgroundColor = UIColor.white
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.position = boardPosition
		
		let cardClicked = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:)))
		cardClicked.numberOfTapsRequired = 1
		newCardView.addGestureRecognizer(cardClicked)
		
		let doubleClick = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.doubleClick(_:)))
		doubleClick.numberOfTapsRequired = 2
		newCardView.addGestureRecognizer(doubleClick)
//		boardView.gravity.addItem(newCardView)
		boardView.addSubview(newCardView)
		newCardView.cardDescription = card.description
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		// Remove cards from freeCells and suitStacks (and cardColumns, for good measure)
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (colIndex, column) in game.board.enumerated() {
			for (rowIndex, card) in column.enumerated() {
				let newCardPosition = Position(column: colIndex, row: rowIndex)
				draw(card: card, at: newCardPosition)
			}
		}
		addGestureRecognizersForEmptyCells()
	}
	
	func addGestureRecognizersForEmptyCells () {
		for view in boardView.subviews {
			if !(view is PlayingCardView) {
				if let cardView = view as? CardView {
					switch game.locationFor(column: cardView.position.column)! {
					case Location.freeCells:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
					case Location.suitStacks:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
					case Location.cardColumns:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.emptyCardColumnClicked(_:))))
					default: break
					}
				}
			}
		}
	}
	
	func startGame () {
		startOfSelection = nil
		game.createBoard()
		game.dealCards()
		updateBoardUI()
		postMoveCleanUp()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		startGame()
	}
}


