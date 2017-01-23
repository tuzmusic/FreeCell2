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
	let freeCellGame = FreeCellBrain()
	
	typealias Position = CardView.FreeCellPosition
	
	var startOfSelection: Position?
	var stackLength: Int? {
		if let selection = startOfSelection {
			return selection.location == .cardColumn ? freeCellGame.board[selection.column].count - selection.row : 1
		}
		return nil
	}
	
	struct FreeCellSelection {
		var column, row, subViewsIndex: Int
		var selectionLocation: FreeCellBoardView.CardType
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	//MARK: Gameplay Utility Functions
	
	func clearSelection() {
		startOfSelection = nil
		for view in boardView.subviews {
			(view as? PlayingCardView)?.isSelected = false
		}
	}
	
	func freeCellIndexOf(cardView: PlayingCardView) -> Int? {
		let col = cardView.position.column
		if col > 7 && col < 12 {
			return col - 8
		}
		return nil
	}
	
	func suitStackIndexOf(cardView: PlayingCardView) -> Int? {
		let col = cardView.position.column
		if col > 12 {
			return col - 12
		}
		return nil
	}
	
	func selectCards(startingWith clickedCardView: PlayingCardView) {
		if let position = clickedCardView.position {
			
			startOfSelection = position
			
			for cardViewIndex in startOfSelection!.subViewsIndex ..< startOfSelection!.subViewsIndex + stackLength! {
				if let currentCardView = boardView.subviews[cardViewIndex] as? PlayingCardView {
					currentCardView.isSelected = true
				}
			}
		}
	}
	
	func move(_ card: PlayingCardView, to cell: CardView) {
		card.frame = cell.frame
		card.isSelected = false
		startOfSelection = nil
		card.position = Position(column: cell.position.column, row: 0, subViewsIndex: boardView.subviews.index(of: card)!, location: .freeCell)
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		print("Card clicked")
		
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			// If there is a selection...
			if let previousSelection = startOfSelection {
				
				// If the selection is in the same column that was just clicked, deselect, and reselect if needed.
				if clickedCardView.position.column == previousSelection.column {
					let oldRow = previousSelection.row
					clearSelection()
					if clickedCardView.position.row != oldRow {
						selectCards(startingWith: clickedCardView)
					}
				} else {
					// Try to move the selected cards (to a cardColumn or suitStack).
				}
			}
			else {
				selectCards(startingWith: clickedCardView)
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		print("Cell \(cell.view!.tag) clicked!")
		if let cellView = cell.view as? CardView {
			if freeCellGame.cells[cellView.tag].isEmpty && stackLength == 1 {
				let cardToMove = boardView.subviews[startOfSelection!.subViewsIndex] as! PlayingCardView
				move(cardToMove, to: cellView)
			}
			if startOfSelection == nil {
				// Select the card in the cell, if any
				//		} else if selection!.length == 1 {
				// If cell is empty, move the card to the cell
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
	
	func create (card: FreeCellBrain.Card, at boardPosition: (Int, Int)) -> PlayingCardView {
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
		freeCellGame.dealCards()
		for column in 0 ..< freeCellGame.board.count {
			for row in 0...(column <= 3 ? 6 : 5) {
				let newCard = create(card: freeCellGame.board[column][row], at: (column, row))
				boardView.addSubview(newCard)
				
				newCard.position = Position(column: column, row: row, subViewsIndex: boardView.subviews.index(of: newCard)!, location: .cardColumn)
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


