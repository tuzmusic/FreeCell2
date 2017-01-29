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
	var freeCellGame = FreeCellBrain() // old model (still used for rules, no?)
	
	// new model!
	var gameBoard = FreeCellBrain().board
	
	typealias Position = CardView.FreeCellPosition
	
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
			return gameBoard[selection.location][selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == Location.cardColumns ? gameBoard[Location.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	var currentlyClickedView: UIView?
	var selectedSpot: FreeCellBrain.Column? {
		if let view = currentlyClickedView {
			return gameBoard[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func redrawBoard(_ sender: UIButton) { updateBoardUI() }
	@IBAction func clearSelection(_ sender: UIButton) { startOfSelection = nil }
	@IBOutlet weak var clear: UIButton!
	@IBOutlet weak var redraw: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to dest: Position) {
		if let source = startOfSelection {
			// Move cards in the model.
			let firstRow = source.row
			for (row, card) in gameBoard[source.location][source.column].enumerated() {
				if row >= firstRow {
					gameBoard[source.location][source.column].remove(at: source.row)
					gameBoard[dest.location][dest.column].append(card)
				}
			}
			print("\r\rAfter Move:"); print("Source row: ", terminator: " ")
			gameBoard[source.location][source.column].forEach { print($0.description, terminator: " ") }
			print("\rDestination row: ", terminator: " ")
			gameBoard[dest.location][dest.column].forEach { print($0.description, terminator: " ") }; print("\r")
			
			for position in [source, dest] {
				// Remove all PlayingCardViews from column
				for view in boardView.subviews
					where (view as? PlayingCardView)?.position.location == position.location
						&& (view as? PlayingCardView)?.position.column == position.column {
							view.removeFromSuperview()
				}
				// Redraw the column
				for (row, card) in gameBoard[position.location][position.column].enumerated() {
					let newPosition = Position(location: position.location, column: position
						.column, row: row)
					let newCard = draw(card: card, at: newPosition)
					boardView.addSubview(newCard)
				}
			}
			startOfSelection = nil
		}
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			currentlyClickedView = clickedCardView
			if startOfSelection == nil
				|| (clickedCardView.position.column == startOfSelection?.column
					&& clickedCardView.position.location == startOfSelection?.location) {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else {
				if let selection = startOfSelection {
					
					// Create the stack to check if it can be moved
					var movingStack = Array<DeckBuilder.Card>()
					let startingRow = selection.row
					for row in startingRow ..< startingRow + stackLength(for: selection)! {
						movingStack.append(gameBoard[selection.location][selection.column][row])
					}
					// See if the stack can be moved, and move it.
					if freeCellGame.canMove(movingStack, toColumn: selectedSpot!) {
						moveSelection(to: clickedCardView.position!)
					}
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) {
		if let clickedCell = cell.view as? PlayingCardView {
			currentlyClickedView = clickedCell
			
			if let selection = startOfSelection {
				// Create the stack to check if it can be moved
				var movingStack = Array<DeckBuilder.Card>()
				let startingRow = selection.row
				for row in startingRow ..< startingRow + stackLength(for: selection)! {
					movingStack.append(gameBoard[selection.location][selection.column][row])
				}
				// See if the stack can be moved, and move it.
				if freeCellGame.canMove(movingStack, toColumn: selectedSpot!) {
					moveSelection(to: clickedCell.position!)
				}
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		if let cellView = cell.view as? CardView {
			currentlyClickedView = cellView
			if selectedSpot?.isEmpty == false {
				if (cellView as! PlayingCardView).isSelected {
					startOfSelection = nil
				} else if startOfSelection == nil {
					startOfSelection = cellView.position
				}
			} else if stackLength(for: startOfSelection) == 1 {
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { //print("Suit clicked!")
		if let suitView = suit.view as? CardView {
			currentlyClickedView = suitView
			if selectedSpot!.isEmpty == false {
				if startOfSelection == nil {
					startOfSelection = suitView.position
				}
				else if (suitView as! PlayingCardView).isSelected {
					startOfSelection = nil
				}
			}
			if stackLength(for: startOfSelection) == 1	// suitStack being empty is handled by the canMove function
				&& freeCellGame.canMove(selectedCard!, toSuitStack:
					gameBoard[suitView.position.location][suitView.position.column]) {
				moveSelection(to: suitView.position)
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
		newCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
		return newCardView
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (locIndex, location) in gameBoard.enumerated() {
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
			if let cardView = view as? CardView {
				switch cardView.position.location {
				case Location.freeCells:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
				case Location.suitStacks:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
				case Location.cardColumns:
					if gameBoard[2][cardView.position.column].isEmpty {
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.emptyCardColumnClicked(_:)))) }
				default: break
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//				gameBoard[0][0].append(FreeCellBrain.Card(rank: .Two, suit: .Spades))
		//				gameBoard[1][0].append(FreeCellBrain.Card(rank: .Ace, suit: .Spades))
		updateBoardUI ()
	}
}


