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

			// Pick the selection we're dealing with.
			// If there was no prior selection, we'll select the new one. If we're clearing the selection, we'll deselect the old ones.
			let selection = newSelection == nil ? oldValue : newSelection
			if let selection = selection {
			
				// Use the subViewsIndex to set the isSelected property on the views. I believe this is the only way to find the view we're looking for.
				for index in selection.subViewsIndex! ..< selection.subViewsIndex! + (stackLength(for: selection) ?? 0) {
					(boardView.subviews[index] as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
			print ("Selection set to: " + (newSelection == nil ? "nil" : selectedCard!.description))
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
	
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func redrawBoard(_ sender: UIButton) { updateBoardUI() }
	@IBAction func clearSelection(_ sender: UIButton) { startOfSelection = nil }
	@IBOutlet weak var clear: UIButton!
	@IBOutlet weak var redraw: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to destPosition: Position) {
		// Move card in the model
		if let selection = startOfSelection {
			for destRow in selection.row ..< selection.row + stackLength(for: selection)! {
				
				// Remove card in model
				// Always use selection.row rather than the interator instance, because removing the first card in the selection slides cards below it into its place.
				let card = gameBoard[selection.location][selection.column].remove(at: selection.row)

				// Remove card in view
				// let cardViewToRemove = boardView.subviews[selection.subViewsIndex!]
				boardView.subviews[selection.subViewsIndex!].removeFromSuperview()
				
				// Move card to its new position in the model
				gameBoard[destPosition.location][destPosition.column].append(card)
				
				// Redraw the card in its new position
				let destCardView = draw(card: card, at: destPosition)
				
				let newSubViewIndex = destPosition.subViewsIndex!
				destCardView.position.subViewsIndex = newSubViewIndex
				boardView.insertSubview(destCardView, belowSubview: boardView.subviews[newSubViewIndex])
				
			}
			refreshGestureRecognizersAndSubViewsIndices()
			startOfSelection = nil
		}
	}
	
	func updateBoardSection () {
		
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { print("Card clicked")
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			currentlyClickedView = clickedCardView
			if startOfSelection == nil || clickedCardView.position.column == startOfSelection?.column {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else {
				if let selection = startOfSelection {
					var movingStack = Array<DeckBuilder.Card>()
					let startingRow = selection.row
					for row in startingRow ..< startingRow + stackLength(for: selection)! {
						movingStack.append(gameBoard[selection.location][selection.column][row])
					}
					if freeCellGame.canMove(movingStack, toColumn: selectedSpot!) {
						var nextPosition = clickedCardView.position!
						nextPosition.row += 1
						moveSelection(to: nextPosition)
					}
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { print("Empty column clicked")
		
	}
	
	var currentlyClickedView: UIView?
	var selectedSpot: FreeCellBrain.Column? {
		if let view = currentlyClickedView {
			return gameBoard[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
		}
		return nil
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) { print("Cell clicked")
		if let cellView = cell.view as? CardView {
			currentlyClickedView = cellView
			if selectedSpot?.isEmpty == false {
				if (cellView as!PlayingCardView).isSelected {
					startOfSelection = nil
				} else if startOfSelection == nil {
					startOfSelection = cellView.position
				}
			} else if stackLength(for: startOfSelection) == 1 {
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { print("Suit clicked!")
		if let suitView = suit.view as? CardView {
			// This didn't work when using selectedSpot. For some reason it would get set twice, the second time to nil.
			currentlyClickedView = suitView
			let spot = selectedSpot!
			print("spot: \(spot)")
			
			if selectedSpot!.isEmpty == false {
				if startOfSelection == nil {
					startOfSelection = suitView.position
				}
				else if (suitView as! PlayingCardView).isSelected {
					startOfSelection = nil
				}
			}
			if stackLength(for: startOfSelection) == 1	// suitStack being empty is handled by the canMove function
				&& freeCellGame.canMove(selectedCard!, toSuitStack: gameBoard[suitView.position.location][suitView.position.column]) {
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
		
		return newCardView
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (locIndex, location) in gameBoard.enumerated() {
			for (colIndex, column) in location.enumerated() {
				for (rowIndex, card) in column.enumerated() {
					let newCardPosition = Position(location: locIndex, column: colIndex, row: rowIndex, subViewsIndex: nil)
					let newCardView = draw(card: card, at: newCardPosition)
					boardView.addSubview(newCardView)
					newCardView.position.subViewsIndex = boardView.subviews.index(of: newCardView)
				}
			}
			refreshGestureRecognizersAndSubViewsIndices()
		}
	}
	
	func refreshGestureRecognizersAndSubViewsIndices () {
		for view in boardView.subviews {
			if let cardView = view as? CardView {
				cardView.position.subViewsIndex = boardView.subviews.index(of: cardView)
				switch cardView.position.location {
				case Location.freeCells:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
				case Location.suitStacks:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
				case Location.cardColumns:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:
						gameBoard[2][cardView.position.column].isEmpty
							? #selector(FreeCellViewController.emptyCardColumnClicked(_:))
							: #selector(FreeCellViewController.cardClicked(_:))))
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


