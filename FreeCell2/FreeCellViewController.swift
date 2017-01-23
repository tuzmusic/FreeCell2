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
	
	var selection: (column: Int, row: Int, subViewsIndex: Int)?
	var stackLength: Int? {
		if let selection = selection {
			return freeCellGame.board[selection.column].count - selection.row
		}
		return nil
	}
	

	
	struct FreeCellSelection {
		var column: Int
		var row: Int
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	//MARK: Gameplay Utility Functions

	func clearSelection() {
		selection = nil
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
			
			selection = position

			for cardViewIndex in selection!.subViewsIndex ..< selection!.subViewsIndex + stackLength! {
				if let currentCardView = boardView.subviews[cardViewIndex] as? PlayingCardView {
					currentCardView.isSelected = true
				}
			}
		}
	}
	
	func move(_ card: PlayingCardView, to cell: CardView) {
		card.frame = cell.frame
		card.isSelected = false
		selection = nil
		card.position = (cell.tag + 8, 0, boardView.subviews.index(of: cell)!)
		print("Card moved to cell \(freeCellIndexOf(cardView: card)!)")
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		print("Card clicked")
		
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			// If there is a selection...
			if let previousSelection = selection {
				
				// If the selection is in the same column that was just clicked, deselect, and reselect if needed.
				// TODO: It looks like the model needs to be rewritten so that the freeCells and suitStacks are part of the board, so they can be addressed via an index.
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
				let cardToMove = boardView.subviews[selection!.subViewsIndex] as! PlayingCardView
				move(cardToMove, to: cellView)
			}
			if selection == nil {
				// Select the card in the cell, if any
				//		} else if selection!.length == 1 {
				// If cell is empty, move the card to the cell
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) {
		print("Suit \(suit.view!.tag) clicked!")
		if selection == nil {
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
 
				newCard.position = (column, row, boardView.subviews.index(of: newCard)!)
				
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		dealCards ()
		for view in boardView.subviews {
			if let cardView = view as? CardView {
				if let cardViewType = cardView.cardViewType {
					switch cardViewType {
					case FreeCellBoardView.TypeNames.freeCell:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
					case FreeCellBoardView.TypeNames.suitStack:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
					case FreeCellBoardView.TypeNames.cardColumn:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
					default: break
					}
				}
			}
		}
	}
}

