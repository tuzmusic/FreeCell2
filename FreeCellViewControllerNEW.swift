//
//  FreeCellViewController-NEW.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class FreeCellViewControllerNEW: UIViewController {
	
	let freeCellGame = FreeCellBrain()
	
	var selection: FreeCellSelection?
	
	struct FreeCellSelection {
		var column: Int
		var row: Int?
		var length: Int?
	}
	
	@IBOutlet var entireTable: UIView!
	
	@IBOutlet weak var columnsView: CardColumnsView! {
		didSet {
			columnsView.columnType = .Column
		}
	}
	
	@IBOutlet weak var suitsView: CardColumnsView! {
		didSet {
			suitsView.columnType = .Stack
		}
	}
	
	@IBOutlet weak var cellsView: CardColumnsView! {
		didSet {
			cellsView.columnType = .Single
		}
	}
	
	// Setup functions
	func create (card: FreeCellBrain.Card, at position: (Int, Int)) -> PlayingCardView {
		let newCardView = PlayingCardView()
		let (column, row) = position
		let columns = columnsView.subviews
		
		newCardView.frame.origin.x = columns[column].frame.minX
		newCardView.frame.origin.y = columnsView.verticalMargin + columnsView.columnCardVerticalSpace * CGFloat(row)
		newCardView.frame.size = columnsView.cardSize
		//deal with square white edges?
		newCardView.backgroundColor = UIColor.white
		newCardView.position = position
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.cardDescription = card.description
		
		return newCardView
	}
	
	func dealCards () {
		freeCellGame.dealCards()
		for column in 0 ..< freeCellGame.board.count {
			for row in 0...(column <= 3 ? 6 : 5) {
				let newCard = create(card: freeCellGame.board[column][row], at: (column, row))
				newCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewControllerNEW.cardClicked(_:))))
				columnsView.addSubview(newCard)
			}
		}
	}
	
	// Gameplay functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) {
		//print("Card clicked")
		if selection == nil {
			if let card = clickedCard.view as? PlayingCardView {
				let (col, row) = card.position!
				selection?.column = col
				selection?.row = row
				
				// Use the view's info to look up the card in the model
				let selectedColumn = freeCellGame.board[col]
				// Use the count info from the model to get how long the column selection should be (1-based)
				let length = (selectedColumn.count) - (row + 1)
				selection?.length = length
				
				// CURRENT IMPLEMENTATION ONLY WORKS FOR COLUMNS (NOT CELLS OR STACKS)
				let firstCardViewIndex = columnsView.subviews.index(of: clickedCard.view!)!
				//print ("Card \(firstCardView - 8) clicked!")
				let lastCardViewIndex = firstCardViewIndex + selectedColumn.count - row - 1
				for cardToSelect in firstCardViewIndex ... lastCardViewIndex {
					if let currentCard = columnsView.subviews[cardToSelect] as? PlayingCardView{
						currentCard.isSelected = currentCard.isSelected ? false : true
					}
				}
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) {
		print("Cell \(cell.view!.tag) clicked!")
		if selection == nil {
			// Select the card in the cell, if any
		} else if selection!.length == 1 {
			// If cell is empty, move the card to the cell
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) {
		print("Suit \(suit.view!.tag) clicked!")
		if selection == nil {
			// Select the top card of the suit
		} else if selection!.length == 1 {
			// Move the selected card
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		dealCards()
		for suitView in suitsView.subviews {
			suitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewControllerNEW.suitClicked(_:))))
		}
		for cellView in cellsView.subviews {
			cellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewControllerNEW.cellClicked(_:))))
		}
	}
	
}
