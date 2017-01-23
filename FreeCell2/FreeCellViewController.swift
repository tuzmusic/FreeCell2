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
	
	var selection: (column: Int, row: Int)?
	
	struct FreeCellSelection {
		var column: Int
		var row: Int
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	//MARK: Gameplay Functions/Click handlers
	
	func clearSelection() {
		selection = nil
		for view in boardView.subviews {
			(view as? PlayingCardView)?.isSelected = false
		}
	}
	
	func selectCards(startingWith clickedCardView: PlayingCardView) {
		if let position = clickedCardView.position {
			
			selection = position
			
			// Look for the card in the entire view.
			// This should include freeCells AND suitStacks! Well, in the view anyway (maybe not in the model)
			if let startingIndex = boardView.subviews.index(of: clickedCardView) {
				let stackLength = freeCellGame.board[selection!.column].count - selection!.row
				for cardViewIndex in startingIndex ..< startingIndex + stackLength {
					if let currentCardView = boardView.subviews[cardViewIndex] as? PlayingCardView {
						currentCardView.isSelected = true
					}
				}
			}
		}
	}
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		//print("Card clicked")
		
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
		if selection == nil {
			// Select the card in the cell, if any
			//		} else if selection!.length == 1 {
			// If cell is empty, move the card to the cell
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
	
	func create (card: FreeCellBrain.Card, at position: (Int, Int)) -> PlayingCardView {
		let newCardView = PlayingCardView()
		let (column, row) = position
		
		newCardView.frame.origin.x = boardView.xValueFor(boardView.cardColumn, number: column)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(row: row)
		newCardView.frame.size = boardView.cardSize
		newCardView.backgroundColor = UIColor.white
		newCardView.position = position
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
				
				//newCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
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

