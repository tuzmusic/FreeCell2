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
	
	// MARK: View
	@IBOutlet var boardView: FreeCellBoardView!
	
	@IBAction func startGame () {
		startOfSelection = nil
		game.emptyBoard()
		game.dealCards()
		resetGameUI()
		postMoveCleanUp()
	}
	
	@IBOutlet weak var restartButton: UIButton!
	
	// MARK: Selection and Board Interaction
	
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
			return game.board[selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			if game.area(for: selection.column) == Area.cardColumns {
				let length = game.board[selection.column].count - selection.row
				return length
			}
			return 1
		}
		return nil
	}

	var lastClickedPosition: Position!
	
	var clickedColumn: FreeCellBrain.Column? {
		//TO-DO: I don't think the full column is needed, only the card at the bottom, right?
			return game.board[lastClickedPosition.column]
	}
	
	//MARK: Gameplay Utility Functions
	
	func move(from source: Position, to dest: Position) {
		
		// we don't need the iterator number because the row is always the same
		// since each time a card is removed, the cards after it bump up their index
		for _ in 1 ... stackLength(for: source)! {
			game.moveCard(from: source, to: dest)	// Move the card in the MODEL
			
			if let movedCard = game.board[dest.column].last {	// Remove and re-place the card in the VIEW
				// TO-DO: This really should find the card in the position instead of searching by name.
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
		if let (oldPos, destStack) = game.cardToMoveToSuitStack() {
			let suitStack = Position(column: destStack, row: game.board[destStack].count-1)
			move(from: oldPos, to: suitStack)
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
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		// TO-DO: What does this comment mean?!?!?
		// This should be ready to test but it wasn't a good time to test it yet.
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			lastClickedPosition = clickedCardView.position
			let position = lastClickedPosition!
			
			// If there was no selection, or the selection was in the same column, get the new selection.
			if startOfSelection == nil || position.column == startOfSelection?.column {
				let oldSelection = startOfSelection
				startOfSelection = nil // Clear the old selection
				if position.row != oldSelection?.row {
					startOfSelection = position // Unless the click was on the same card (to clear selection), get new selection.
				}
			} else if let selection = startOfSelection {
				let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
				// TO-DO: Move all this "can we move it?" checking to the Brain!!!
				// See if the stack can be moved, and move it.
				if (game.area(for: position.column) == Area.cardColumns
					&& game.canMove(movingStack, toColumn: clickedColumn!))
					|| (game.area(for: position.column) == Area.suitStacks
						&& movingStack.count == 1
						&& game.canMove(selectedCard!, to: clickedColumn!)) {
					move(from: selection, to: position)
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) {
		if let clickedCell = cell.view as? CardView {
			lastClickedPosition = clickedCell.position
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
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		if let cellView = cell.view as? CardView {
			lastClickedPosition = cellView.position
			if stackLength(for: startOfSelection) == 1 {
				move(from: startOfSelection!, to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) {
		if let suitView = suit.view as? CardView {
			lastClickedPosition = suitView.position
			if stackLength(for: startOfSelection) == 1 && game.canMove(selectedCard!, to: clickedColumn!) {
				move(from: startOfSelection!, to: suitView.position)
			}
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			if stackLength(for: startOfSelection) == 1 {
				for (index, suit) in game.board.enumerated() where game.area(for: index) == Area.suitStacks {
					if game.canMove(selectedCard!, to: suit) {
						let destPosition = Position(column: index, row: 0)
						move(from: clickedCardView.position, to: destPosition)
						return
					}
				}
				for (index, cell) in game.board.enumerated() where game.area(for: index) == Area.freeCells {
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
		let area = game.area(for: boardPosition.column)!
		let columnOffset = area.rawValue * 4

		// Place (and color) cardview
		newCardView.frame.origin.x = boardView.xValueForCard(in: area, column: boardPosition.column - columnOffset)
		newCardView.frame.origin.y = boardView.yCoordinateForCard(in: area, row: boardPosition.row)
		newCardView.frame.size = boardView.cardSize
		newCardView.backgroundColor = UIColor.white
		
		// Add gesture recognizers
		let cardClicked = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:)))
		cardClicked.numberOfTapsRequired = 1
		newCardView.addGestureRecognizer(cardClicked)
		
		let doubleClick = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.doubleClick(_:)))
		doubleClick.numberOfTapsRequired = 2
		newCardView.addGestureRecognizer(doubleClick)
		
		boardView.addSubview(newCardView)
		
		// Model-related attributes
		newCardView.cardDescription = card.description
		newCardView.cardColor = card.color == .Red ? .red : .black
		newCardView.position = boardPosition
	}
	
	func resetGameUI () {
		startOfSelection = nil
		
		for view in boardView.subviews {
			(view as? PlayingCardView)?.removeFromSuperview()
		}
		
		for (colIndex, column) in game.board.enumerated() {
			for (rowIndex, card) in column.enumerated() {
				let newCardPosition = Position(column: colIndex, row: rowIndex)
				draw(card: card, at: newCardPosition)
			}
		}
		addGestureRecognizersForEmptyCells()
	}
	
	func addGestureRecognizersForEmptyCells () {
		for view in boardView.subviews where !(view is PlayingCardView) {
			if let cardView = view as? CardView {
				let area = game.area(for: cardView.position.column)!
				switch area {
				case .freeCells:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
				case .suitStacks:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
				case .cardColumns:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.emptyCardColumnClicked(_:))))
				default: break
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		startGame()
	}
}


