//
//  ViewController.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

// TODO:
// Animation

class FreeCellViewController: UIViewController {
	
	// MARK: Model
	var game = FreeCellBrain()
	
	var startOfSelection: NewPosition? {
		
		//TODO: This still deals with cardView positions!
		didSet {
			// this simply deals with selecting or de-selecting the views
			
			// If we're setting a new selection, we'll deal with the new selection, and select it.
			// If we're setting the selection to nil, we'll deal with the old selection, and deselect it.
			let newSelection = startOfSelection
			let selection = newSelection == nil ? oldValue : newSelection
			
			if let start = selection {
				// Yes this is actually a loop, because we're selecting or deselecting multiple cards.
				for view in boardView.subviews where view is PlayingCardView
						&& (view as! PlayingCardView).position.column == start.column
						&& (view as! PlayingCardView).position.row >= start.row {
							(view as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
		}
	}
	
	var selectedCard: FreeCellBrain.Card? {
		if let selection = startOfSelection {
			return game.cardAt(position: selection)
			//return game.board[selection.location][selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: NewPosition?) -> Int? {
		if let selection = selection {
			if game.locationForColumnIndex(selection.column) == Location.cardColumns {
				let length = game.board[selection.column].count - selection.row
				print("length = \(length)")
				return length
			}
			return 1
			
			//return selection.location == Location.cardColumns ? game.board[Location.cardColumns][selection.column].count - selection.row : 1
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
	var lastClickedPosition: NewPosition? {
		if let description = (lastClickedView as? PlayingCardView)?.cardDescription {
			return game.positionForCardWith(description: description)
		}
		return nil
	}
	
	var clickedColumn: FreeCellBrain.Column? {
		if let position = lastClickedPosition {
			return game.board[position.column]
		}
	//		if let description = (lastClickedView as? PlayingCardView)?.cardDescription {
	//			if let position = game.positionForCardWith(description: description) {
	//				return game.board[position.location][position.column]
	//			}
	//		}
//		if let view = lastClickedView {
//			return game.board[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
//		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func restartGame(_ sender: UIButton) { startGame() }
	@IBOutlet weak var restartButton: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func move(from source: NewPosition, to dest: NewPosition) {
		
		// we don't need the iterator number because the row is always the same
		// since each time a card is removed, the cards after it bump up their index
		for _ in 1 ... stackLength(for: source)! {
			// Move the card in the model
			game.moveCard(from: source, to: dest)
			// Move the card in the view
			if let movedCard = game.board[dest.column].last {
				// Find the subview by its description
				if let view = boardView.subviews.first(where: { ($0 as? PlayingCardView)?.cardDescription == movedCard.description  }) {
					view.removeFromSuperview()
				}
				let destRow = game.board[dest.column].count - 1
				let destPosition = NewPosition(column: dest.column, row: destRow)
				draw(card: movedCard, at: destPosition)
			}
		}
		startOfSelection = nil
		postMoveCleanUp()
	}
	
	func postMoveCleanUp() { //print("cleanup")
		
		if let autoMove = game.cardToMoveToSuitStack() {
			let suitStack = NewPosition(column: autoMove.destStackIndex, row: game.board[autoMove.destStackIndex].count-1)
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
//	func cardClickedOLD (_ clickedCard: UITapGestureRecognizer) { //print("Card clicked!")
//		if let clickedCardView = clickedCard.view as? PlayingCardView { lastClickedView = clickedCardView
//			if startOfSelection == nil
//				|| clickedCardView.position.column == startOfSelection?.column
//					 {
//				let oldSelection = startOfSelection
//				startOfSelection = nil
//				if clickedCardView.position.row != oldSelection?.row {
//					startOfSelection = game.positionForCardWith(description: clickedCardView.cardDescription!)
//				}
//			} else if let selection = startOfSelection {
//				let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
//				// See if the stack can be moved, and move it.
//				if (game.columnIs(in: Location.cardColumns, column: clickedCardView.position.column)
//					&& game.canMove(movingStack, toColumn: clickedColumn!))
//					|| (clickedCardView.position.location == Location.suitStacks
//						&& movingStack.count == 1
//						&& game.canMove(selectedCard!, to: clickedColumn!)) {
//					move(from: selection, to: clickedCardView.position!)
//				}
//			}
//		}
//	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { print("Empty column clicked!")
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
	
	func cellClicked (_ cell: UITapGestureRecognizer) { print("Cell clicked!")
		if let cellView = cell.view as? CardView { lastClickedView = cellView
			if stackLength(for: startOfSelection) == 1 {
				move(from: startOfSelection!, to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { print("Suit clicked!")
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
						let destNewPosition = NewPosition(column: index, row: 0)
						move(from: clickedCardView.position, to: destNewPosition)
						return
					}
				}
				for (index, cell) in game.board.enumerated() where game.columnIs(in: Location.freeCells, column: index) {
					if cell.isEmpty {
						let destNewPosition = NewPosition(column: index, row: 0)
						move(from: clickedCardView.position, to: destNewPosition)
						return
					}
				}
			}
		}
	}
	
	// MARK: Setup functions
	
	func draw (card: FreeCellBrain.Card, at boardPosition: NewPosition) {
		print("drawing card: \(card.description)")
		
		let newCardView = PlayingCardView()
		
		var columnOffset = 0
		switch game.locationForColumnIndex(boardPosition.column)! {
		case 1: columnOffset = 4; case 2: columnOffset = 8; default: break
		}
		
		newCardView.frame.origin.x = boardView.xValueForCardIn(location: game.locationForColumnIndex(boardPosition.column)!,
		                                                       column: boardPosition.column - columnOffset)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(game.locationForColumnIndex(boardPosition.column)!,
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
		
		boardView.addSubview(newCardView)
		newCardView.cardDescription = card.description
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		// Remove cards from freeCells and suitStacks (and cardColumns, for good measure)
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (colIndex, column) in game.board.enumerated() {
			for (rowIndex, card) in column.enumerated() {
				let newCardPosition = NewPosition(column: colIndex, row: rowIndex)
				draw(card: card, at: newCardPosition)
			}
		}
		addGestureRecognizersForEmptyCells()
	}
	
	func addGestureRecognizersForEmptyCells () {
		for view in boardView.subviews {
			if !(view is PlayingCardView) {
				if let cardView = view as? CardView {
					switch game.locationForColumnIndex(cardView.position.column)! {
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


