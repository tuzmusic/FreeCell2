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
	
	
	// MARK: Gameplay helper functions
	
	func getNewSelection(at position: Position) {
		let oldSelection = startOfSelection
		startOfSelection = nil // Clear the old selection. NOTE: This belongs here and not in an else clause below, otherwise you can't select, say, one card in a row that currently has more than one card selected, without a few add'l deselecting clicks
		if position.row != oldSelection?.row {
			startOfSelection = position // Unless the click was on the same card (to clear selection), get new selection.
		}
	}
	
	func tryToMoveSelection(at selection: Position, to position: Position) {
		guard let area = game.area(for: position.column) else { return }
		let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
		// TO-DO: Move all this "can we move it?" checking to the Brain!!!
		// See if the stack can be moved, and move it.
		switch area {
		case .cardColumns:
			if game.canMove(movingStack, toColumn: clickedColumn!) {
				move(from: selection, to: position)
			}
		case .suitStacks:
			if movingStack.count == 1 && game.canMove(selectedCard!, toStack: clickedColumn!) {
				move(from: selection, to: position)
			}
		default: break
		}
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		guard let clickedCardView = clickedCard.view as? PlayingCardView else { return }
		lastClickedPosition = clickedCardView.position
		
		if startOfSelection == nil || lastClickedPosition.column == startOfSelection?.column {
			getNewSelection(at: lastClickedPosition!)
		} else if let selection = startOfSelection {
			tryToMoveSelection(at: selection, to: lastClickedPosition!)
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) {
		guard let clickedCell = cell.view as? CardView,
			let selection = startOfSelection else { return }
		lastClickedPosition = clickedCell.position
		let movingStack = Array(game.board[selection.column].suffix(from: selection.row))
		if game.canMove(movingStack, toColumn: clickedColumn!) {
			move(from: selection, to: clickedCell.position!)
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		guard let cellView = cell.view as? CardView else { return }
		lastClickedPosition = cellView.position
		if stackLength(for: startOfSelection) == 1 {
			move(from: startOfSelection!, to: cellView.position)
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) {
		guard let suitView = suit.view as? CardView else { return }
		lastClickedPosition = suitView.position
		if stackLength(for: startOfSelection) == 1 && game.canMove(selectedCard!, toStack: clickedColumn!) {
			move(from: startOfSelection!, to: suitView.position)
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		guard let clickedCardView = clickedCard.view as? PlayingCardView else { return }
		guard stackLength(for: startOfSelection) == 1 else { return }
		
		for (index, suit) in game.board.enumerated() where game.area(for: index) == .suitStacks {
			if game.canMove(selectedCard!, toStack: suit) {
				let destPosition = Position(column: index, row: 0)
				move(from: clickedCardView.position, to: destPosition)
				return
			}
		}
		for (index, cell) in game.board.enumerated() where game.area(for: index) == .freeCells {
			if cell.isEmpty {
				let destPosition = Position(column: index, row: 0)
				move(from: clickedCardView.position, to: destPosition)
				return
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
		
		for (col, column) in game.board.enumerated() {
			for (row, card) in column.enumerated() {
				let newCardPosition = Position(column: col, row: row)
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
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		startGame()
	}
}


