//
//  ViewController.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

// TODO: 
// Double-click
// shouldMoveTo(suitStack), at least for just the one next one
// Animation

class FreeCellViewController: UIViewController {
	
	typealias Position = CardView.FreeCellPosition
	
	// MARK: Model
	var freeCellGame = FreeCellBrain() // old model (still used for rules, no?)
	
	var startOfSelection: Position? {
		didSet { // this simply deals with selecting or de-selecting the views
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
			return freeCellGame.board[selection.location][selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == Location.cardColumns ? freeCellGame.board[Location.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	var lastClickedView: UIView?
	var clickedColumn: FreeCellBrain.Column? {
		if let view = lastClickedView {
			return freeCellGame.board[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func redrawBoard(_ sender: UIButton) { updateBoardUI() }
	@IBAction func clearSelection(_ sender: UIButton) {
		startOfSelection = nil
		freeCellGame.createBoard()
		freeCellGame.dealCards()
		updateBoardUI()
	}
	@IBOutlet weak var clear: UIButton!
	@IBOutlet weak var redraw: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to dest: Position) {
		if let source = startOfSelection {
			// Current implementation erases and redraws the entire columns.
			// Move cards in the model.
			let firstRow = source.row
			for (row, card) in freeCellGame.board[source.location][source.column].enumerated() {
				if row >= firstRow {
					freeCellGame.board[source.location][source.column].remove(at: source.row)
					freeCellGame.board[dest.location][dest.column].append(card)
				}
			}
			for position in [source, dest] {
				// Remove all PlayingCardViews from column
				for view in boardView.subviews
					where (view as? PlayingCardView)?.position.location == position.location
						&& (view as? PlayingCardView)?.position.column == position.column {
							view.removeFromSuperview()
				}
				// Redraw the column
				for (row, card) in freeCellGame.board[position.location][position.column].enumerated() {
					let newPosition = Position(location: position.location, column: position
						.column, row: row)
					let newCard = draw(card: card, at: newPosition)
					boardView.addSubview(newCard)
				}
			}
			startOfSelection = nil
			if freeCellGame.gameIsWon() {
				gameWon()
			} else if freeCellGame.noMovesLeft() {
				gameLost()
			}
		}
	}
	
	func gameWon () {
		print("You won!")
	}
	
	func gameLost () {
		print("No moves left!")
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { print("Card clicked!")
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
				let movingStack = Array(freeCellGame.board[selection.location][selection.column].suffix(from: selection.row))
				// See if the stack can be moved, and move it.
				if (clickedCardView.position.location == Location.cardColumns
					&& freeCellGame.canMove(movingStack, toColumn: clickedColumn!))
					|| (clickedCardView.position.location == Location.suitStacks
						&& movingStack.count == 1
						&& freeCellGame.canMove(selectedCard!, toSuitStack: clickedColumn!)) {
					moveSelection(to: clickedCardView.position!)
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { //print("Empty column clicked!")
		if let clickedCell = cell.view as? CardView {
			lastClickedView = clickedCell
			
			if let selection = startOfSelection {
				// Create the stack to check if it can be moved
				let movingStack = Array(freeCellGame.board[selection.location][selection.column].suffix(from: selection.row))

				// See if the stack can be moved, and move it.
				if freeCellGame.canMove(movingStack, toColumn: clickedColumn!) {
					moveSelection(to: clickedCell.position!)
				}
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) { //print("Cell clicked!")
		if let cellView = cell.view as? CardView { lastClickedView = cellView
			if stackLength(for: startOfSelection) == 1 {
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { //print("Suit clicked!")
		if let suitView = suit.view as? CardView { lastClickedView = suitView
			if stackLength(for: startOfSelection) == 1 && freeCellGame.canMove(selectedCard!, toSuitStack: clickedColumn!) {
				moveSelection(to: suitView.position)
			}
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			startOfSelection = clickedCardView.position
			if stackLength(for: startOfSelection) == 1 {
				for (index, suit) in freeCellGame.board[Location.suitStacks].enumerated() {
					if freeCellGame.canMove(selectedCard!, toSuitStack: suit) {
						let destPosition = Position(location: Location.suitStacks, column: index, row: 0)
						moveSelection(to: destPosition)
						return
					}
				}
				for (index, cell) in freeCellGame.board[Location.freeCells].enumerated() {
					if cell.isEmpty {
						let destPosition = Position(location: Location.freeCells, column: index, row: 0)
						moveSelection(to: destPosition)
						return
					}
				}

			}
		}
	}
	
	// MARK: Setup functions
	
	func draw (card: FreeCellBrain.Card, at boardPosition: Position) -> PlayingCardView {
		let newCardView = PlayingCardView()
		
		newCardView.frame.origin.x = boardView.xValueForCardIn(location: boardPosition.location, column: boardPosition.column)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(boardPosition.location, row: boardPosition.row)
		newCardView.frame.size = boardView.cardSize
		
		newCardView.backgroundColor = UIColor.white
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.cardDescription = card.description
		newCardView.position = boardPosition
		let cardClicked = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:)))
		cardClicked.numberOfTapsRequired = 1
		newCardView.addGestureRecognizer(cardClicked)
		
		let doubleClick = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.doubleClick(_:)))
		doubleClick.numberOfTapsRequired = 2
		newCardView.addGestureRecognizer(doubleClick)
		
		return newCardView
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (locIndex, location) in freeCellGame.board.enumerated() {
			for (colIndex, column) in location.enumerated() {
				for (rowIndex, card) in column.enumerated() {
					let newCardPosition = Position(location: locIndex, column: colIndex, row: rowIndex)
					let newCardView = draw(card: card, at: newCardPosition)
					boardView.addSubview(newCardView)
				}
			}
		}
		addGestureRecognizers()
	}
	
	func addGestureRecognizers () {
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
	
	override func viewDidAppear(_ animated: Bool) {
		//		freeCellGame.board[0][0].append(FreeCellBrain.Card(rank: .Two, suit: .Spades))
		//		freeCellGame.board[1][0].append(FreeCellBrain.Card(rank: .Ace, suit: .Spades))
//				freeCellGame.board[2][2].removeAll()
		updateBoardUI ()
	}
}


