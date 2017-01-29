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
				print("\rSelected:", separator: ",", terminator: " ")
				for index in selection.subViewsIndex! ..< selection.subViewsIndex! + (stackLength(for: selection) ?? 0) {
					if let cardView = boardView.subviews[index] as? PlayingCardView {
						if newSelection == nil {
							cardView.isSelected = false
						} else {
							cardView.isSelected = true
							print(cardView.cardDescription! + " @ \(cardView.position.subViewsIndex!),", separator: "", terminator: " ")
						}
					}
					
					(boardView.subviews[index] as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
			//print ("Selection set to: " + (newSelection == nil ? "nil" : selectedCard!.description))
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
		
		// This is called individually for EACH card in the stack! Therefore this shouldn't require any loops.
		// But it still operates off the "global" selection, NOT a passed stack. This is the first problem.
		
		if let selection = startOfSelection {
			
			// Remove card in model
			let card = gameBoard[selection.location][selection.column].remove(at: selection.row)
			
			// Remove card from view: let cardViewToRemove = boardView.subviews[selection.subViewsIndex!]
			boardView.subviews[selection.subViewsIndex!].removeFromSuperview()
			
			// Move card to its new position in the model
			gameBoard[destPosition.location][destPosition.column].append(card)
			
			// Redraw the card in its new position (when moving to a cardColumn, position.row has already been increased by 1
			let destCardView = draw(card: card, at: destPosition)
			boardView.insertSubview(destCardView, at: destPosition.subViewsIndex!)

			
//			for _ in selection.row ..< selection.row + stackLength(for: selection)! {
//				
//				// Remove card in model
//				let card = gameBoard[selection.location][selection.column].remove(at: selection.row)
//
//				// Remove card from view: let cardViewToRemove = boardView.subviews[selection.subViewsIndex!]
//				boardView.subviews[selection.subViewsIndex!].removeFromSuperview()
//				
//				// Move card to its new position in the model
//				gameBoard[destPosition.location][destPosition.column].append(card)
//				
//				// Redraw the card in its new position (when moving to a cardColumn, position.row has already been increased by 1
//				let destCardView = draw(card: card, at: destPosition)
//				boardView.insertSubview(destCardView, at: destPosition.subViewsIndex!)
//			}
			
			refreshGestureRecognizersAndSubViewsIndices()
			startOfSelection = nil
		}
	}
	
	func updateBoardSection () {
		
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			//print("Card clicked: \(clickedCardView.cardDescription!) at index \(clickedCardView.position.subViewsIndex!)")
			currentlyClickedView = clickedCardView
			if startOfSelection == nil ||
				(clickedCardView.position.column == startOfSelection?.column
					&& clickedCardView.position.location == startOfSelection?.location) {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else {
				if let selection = startOfSelection {
					// Create the stack to move
					var movingStack = Array<DeckBuilder.Card>()
					let startingRow = selection.row
					for row in startingRow ..< startingRow + stackLength(for: selection)! {
						movingStack.append(gameBoard[selection.location][selection.column][row])
					}
					
					if freeCellGame.canMove(movingStack, toColumn: selectedSpot!) {
						// Set the destination position, which is the row and subViewIndex after clicked position
						var nextPosition = clickedCardView.position!
						nextPosition.row += 1
						nextPosition.subViewsIndex! += 1
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
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		if let cellView = cell.view as? CardView {
			print("Cell clicked at index \(cellView.position.subViewsIndex!)")
			currentlyClickedView = cellView
			if selectedSpot?.isEmpty == false {
				// Find the cardView in the cell
				
				
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


