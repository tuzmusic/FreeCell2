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
	
	var startOfSelection: Position? {
		didSet {
			// this simply deals with selecting or de-selecting the views
			let newSelection = startOfSelection
			let selection = newSelection == nil ? oldValue : newSelection
			
			if let selection = selection {
				let start = selection
				for view in boardView.subviews
					where view is PlayingCardView && (view as! PlayingCardView).position.location == start.location
						&& (view as! PlayingCardView).position.column == start.column
						&& (view as! PlayingCardView).position.row >= start.row {
							(view as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
		}
	}
	
	var selectedCard: FreeCellBrain.Card? {
		if let selection = startOfSelection {
			return game.board[selection.location][selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == Location.cardColumns ? game.board[Location.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	var lastClickedView: UIView?
	var clickedColumn: FreeCellBrain.Column? {
		if let view = lastClickedView {
			return game.board[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func restartGame(_ sender: UIButton) { startGame() }
	@IBOutlet weak var restartButton: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func move(from source: Position, to dest: Position) {
		
		// we don't need the iterator number because the row is always the same
		// since each time a card is removed, the cards after it bump up their index
		for _ in 1 ... stackLength(for: source)! {
			// Move the card in the model
			game.moveCard(from: source, to: dest)
			// Move the card in the view
			if let movedCard = game.board[dest.location][dest.column].last {
				for view in boardView.subviews
					where (view as? PlayingCardView)?.cardDescription == movedCard.description {
						view.removeFromSuperview()
				}
				let destRow = game.board[dest.location][dest.column].count - 1
				let destPosition = Position(location: dest.location, column: dest.column, row: destRow)
				draw(card: movedCard, at: destPosition)
			}
		}
		startOfSelection = nil
		postMoveCleanUp()
	}
	
	func postMoveCleanUp() { //print("cleanup")
		
		if let autoMove = game.cardToMoveToSuitStack() {
			let suitStack = Position(location: Location.suitStacks, column: autoMove.stackIndex, row: game.board[1][autoMove.stackIndex].count-1)
			move(from: autoMove.cardPosition, to: suitStack)
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
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { //print("Card clicked!")
		if let clickedCardView = clickedCard.view as? PlayingCardView { lastClickedView = clickedCardView
			if startOfSelection == nil
				|| (clickedCardView.position.column == startOfSelection?.column
					&& clickedCardView.position.location == startOfSelection?.location) {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else if let selection = startOfSelection {
				let movingStack = Array(game.board[selection.location][selection.column].suffix(from: selection.row))
				// See if the stack can be moved, and move it.
				if (clickedCardView.position.location == Location.cardColumns
					&& game.canMove(movingStack, toColumn: clickedColumn!))
					|| (clickedCardView.position.location == Location.suitStacks
						&& movingStack.count == 1
						&& game.canMove(selectedCard!, toSuitStack: clickedColumn!)) {
					move(from: selection, to: clickedCardView.position!)
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { //print("Empty column clicked!")
		if let clickedCell = cell.view as? CardView {
			lastClickedView = clickedCell
			
			if let selection = startOfSelection {
				// Create the stack to check if it can be moved
				let movingStack = Array(game.board[selection.location][selection.column].suffix(from: selection.row))
				
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
			if stackLength(for: startOfSelection) == 1 && game.canMove(selectedCard!, toSuitStack: clickedColumn!) {
				move(from: startOfSelection!, to: suitView.position)
			}
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			if stackLength(for: startOfSelection) == 1 {
				for (index, suit) in game.board[Location.suitStacks].enumerated() {
					if game.canMove(selectedCard!, toSuitStack: suit) {
						let destPosition = Position(location: Location.suitStacks, column: index, row: 0)
						move(from: clickedCardView.position, to: destPosition)
						return
					}
				}
				for (index, cell) in game.board[Location.freeCells].enumerated() {
					if cell.isEmpty {
						let destPosition = Position(location: Location.freeCells, column: index, row: 0)
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
		
		newCardView.frame.origin.x = boardView.xValueForCardIn(location: boardPosition.location, column: boardPosition.column)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(boardPosition.location, row: boardPosition.row)
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
		
		for (locIndex, location) in game.board.enumerated() {
			for (colIndex, column) in location.enumerated() {
				for (rowIndex, card) in column.enumerated() {
					let newCardPosition = Position(location: locIndex, column: colIndex, row: rowIndex)
					draw(card: card, at: newCardPosition)
				}
			}
		}
		addGestureRecognizersForEmptyCells()
	}
	
	func addGestureRecognizersForEmptyCells () {
		for view in boardView.subviews {
			if !(view is PlayingCardView) {
				if let cardView = view as? CardView {
					switch cardView.position.location {
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


