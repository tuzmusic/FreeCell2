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
	var gameBoard = FreeCellBrain().board {
		didSet {
			print("Model changed, re-dealing.")
			dealCards()
		}
	}
	
	typealias Position = CardView.FreeCellPosition

	struct Locations {
		static let freeCells = 0
		static let suitStacks = 1
		static let cardColumns = 2
	}

	var startOfSelection: Position? {
		didSet {
			let newSelection = startOfSelection
			let selection = newSelection == nil ? oldValue : newSelection

			if let selection = selection {
				for index in selection.subViewsIndex ..< selection.subViewsIndex + (stackLength(for: selection) ?? 0) {
					(boardView.subviews[index] as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
		}
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == .cardColumn ? gameBoard[Locations.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to destPosition: Position) {
		// Move card in the model
		if let selection = startOfSelection {
			
			//[selection.column].removeLast()
			
			let card = gameBoard[selection.location.rawValue][selection.column].removeLast()
			gameBoard[destPosition.location.rawValue][destPosition.column].append(card)
//			var card: FreeCellBrain.Card!
//			// TODO: Isn't there a more elegant way to do this?
//			switch selection.location {
//			case .cardColumn:
//				card = gameBoard[Locations.cardColumns][selection.column].removeLast()
//			case .freeCell:
//				card = gameBoard.freeCells[selection.column].removeLast()
//			case .suitStack:
//				card = gameBoard.suitStacks[selection.column].removeLast()
//			}
//			switch destPosition.location {
//			case .cardColumn:
//				gameBoard[Locations.cardColumns][selection.column].append(card)
//			case .freeCell:
//				gameBoard.freeCells[selection.column].append(card)
//			case .suitStack:
//				gameBoard.suitStacks[selection.column].append(card)
//			}
			dealCards()
		}
		
	}
	
	func move(_ cardView: PlayingCardView, to destination: CardView) {
		cardView.frame = destination.frame
		
		// Move the card in the model
		
		// Possibly write a didSet for CardView.position that moves the card's frame when its position is changed.
		
		cardView.position = Position(column: destination.position.column, row: destination.position.row,
		                         subViewsIndex: boardView.subviews.index(of: cardView)!, location: destination.position.location)
		startOfSelection = nil

	
	}
	
	// MARK: Gameplay action functions
	
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
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

	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		//print("Cell \(cell.view!.tag) clicked!")
		if let cellView = cell.view as? CardView {
			if gameBoard[Locations.freeCells][cellView.position.column].isEmpty && stackLength(for: startOfSelection) == 1 {
				//let cardToMove = boardView.subviews[startOfSelection!.subViewsIndex] as! PlayingCardView
				//move(cardToMove, to: cellView)
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) {
		print("Suit \(suit.view!.tag) clicked!")
		if startOfSelection == nil {
			// Select the top card of the suit
			//		} else if selection!.length == 1 {
			// Move the selected card if possible
		}
	}
	
	// MARK: Setup functions
	
	func draw (card: FreeCellBrain.Card, at boardPosition: (Int, Int)) -> PlayingCardView {
		let newCardView = PlayingCardView()
		let (column, row) = boardPosition
		
		newCardView.frame.origin.x = boardView.xValueFor(boardView.cardColumn, number: column)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(row: row)
		newCardView.frame.size = boardView.cardSize
		newCardView.backgroundColor = UIColor.white
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.cardDescription = card.description
		newCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
		
		return newCardView
	}
	
	
	func dealCards () {
		let columnCount = gameBoard[Locations.cardColumns].count
		for column in 0 ..< columnCount {
			for row in 0 ..< gameBoard[Locations.cardColumns][column].count {
				let newCardView = draw(card: gameBoard[Locations.cardColumns][column][row], at: (column, row))
				boardView.addSubview(newCardView)
				
				newCardView.position = Position(column: column, row: row, subViewsIndex: boardView.subviews.index(of: newCardView)!, location: .cardColumn)
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		dealCards ()
		for view in boardView.subviews {
			if let cardView = view as? CardView {
				switch cardView.position.location {
				case .freeCell:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
				case .suitStack:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
				case .cardColumn:
					cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
				}
			}
		}
	}
}


