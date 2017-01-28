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
			// If there was no prior selection, we'll select the new one. If we're clearing the selection, we'll deselect the old ones.
			// We'll use the subViewsIndex to set the isSelected property on the views. I believe this is the only way to find the view we're looking for.
			let selection = newSelection == nil ? oldValue : newSelection
			if let selection = selection {
				// this should crash because I haven't been able
				for index in selection.subViewsIndex! ..< selection.subViewsIndex! + (stackLength(for: selection) ?? 0) {
					(boardView.subviews[index] as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
		}
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == Location.cardColumns ? gameBoard[Location.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to destPosition: Position) {
		// Move card in the model
		if let selection = startOfSelection {
			let card = gameBoard[selection.location][selection.column].removeLast()
			gameBoard[destPosition.location][destPosition.column].append(
				card)
			updateBoardUI()
		}
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { //print("Card clicked")
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			if startOfSelection == nil || clickedCardView.position.column == startOfSelection?.column {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else {
				// Try to move the selected cards (to a cardColumn or suitStack).
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { print("Empty column clicked")
		
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) { print("Cell clicked")
		if let cellView = cell.view as? CardView {
			if gameBoard[Location.freeCells][cellView.position.column].isEmpty == false {
				startOfSelection = (cellView as! PlayingCardView).isSelected ? nil : cellView.position
			} else if stackLength(for: startOfSelection) == 1 {
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { print("Suit \(suit.view!.tag) clicked!")
		if let suitView = suit.view as? CardView {
			if startOfSelection == nil {
				startOfSelection = suitView.position
			} else if stackLength(for: startOfSelection) == 1 {
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
		}
		// Note: this does indeed need to be separate from the above, because it deals with empty cells whereas above we are just dealing with PlayingCardViews
		for view in boardView.subviews {
			if let cardView = view as? CardView {
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
		gameBoard[0][0].append(FreeCellBrain.Card(rank: .Two, suit: .Spades))
		gameBoard[1][0].append(FreeCellBrain.Card(rank: .Ace, suit: .Spades))
		updateBoardUI ()
	}
}


