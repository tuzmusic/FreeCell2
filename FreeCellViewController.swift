//
//  ViewController.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Foundation

class FreeCellViewController: UIViewController {
	
	// MARK: Model
	
	let freeCellGame = FreeCellBrain()
	var activeStack: FreeCellBrain.CardStack?
	var destinationColumn: FreeCellBrain.Column?

	var boardForView = [[PlayingCardView]](repeatElement([PlayingCardView](), count: 8))
	
	@IBOutlet var boardView: FreeCellBoardView! {
		didSet {
			dealCards()
		}
	}
	
	func create (card: FreeCellBrain.Card, at position: (Int, Int)) -> PlayingCardView {
		let newCardView = PlayingCardView()
		let (column, row) = position
		
		newCardView.frame.origin.x = boardView.columnsInset + (boardView.cardWidth + boardView.spaceBetweenColumns) * CGFloat(column)
		newCardView.frame.origin.y = boardView.verticalInsetForColumns + boardView.spaceBetweenStackedCards * CGFloat(row)
		newCardView.frame.size = boardView.cardSize

		newCardView.backgroundColor = UIColor.white
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.cardDescription = card.description

		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.selectStackOrTryMove(_:)))
		newCardView.isUserInteractionEnabled = true
		newCardView.addGestureRecognizer(singleTap)
		
		return newCardView
	}
	
	func dealCards() {
		freeCellGame.dealCards()
		//Create cardViews for entire board
		var cardsOnBoard = 0
		for row in 0...6 {
			for column in 0...(freeCellGame.board.count - 1) {
				if cardsOnBoard < freeCellGame.board.joined().count {
					let newCard = create(card: freeCellGame.board[column][row], at: (column, row))
					boardForView[column].append(newCard)
					boardView.addSubview(newCard)
					cardsOnBoard += 1
				}
			}
		}
	}
	
	// MARK: Gameplay (Controller)
	
	var cardViewStack = ArraySlice<PlayingCardView>()
	var selectedStack: SelectedStack?
	
	struct SelectedStack {
		// This information is actually "generic" between the model (freeCellGame) and the view (boardForView)
  // It can be used by either.
		
		var col: Int?
		var row: Int?
		var length: Int?
		
		var description: [String]?
		
		init (startingAt position: (Int, Int), length: Int) {
			self.col = position.0
			self.row = position.1
			self.length = length
		}
	}
	
	func stackModelDescription(stack: SelectedStack) -> [String] {
		var cards = [String]()
		let startingRow = stack.row!
		if let length = stack.length {
			for row in startingRow...(startingRow + length - 1) {
				cards.append(freeCellGame.board[stack.col!][row].description)
			}
		}
		return cards
	}
	
	func clearSelectedStack() {
		cardViewStack.forEach({ $0.isSelected = false })
		selectedStack = nil
		cardViewStack.removeAll()
	}
	
	func selectStack (startingWith cardView: PlayingCardView) {

		//	Go through each column to find the card
		for column in 0...(boardForView.count - 1) {
			
			// If card is found in this column, select its stack
			if let row = boardForView[column].index(of: cardView) {
				
				let stackLength = boardForView[column].count - row
				
				var oneCardUp: PlayingCardView? {
					if row > 0 {
						return boardForView[column][row - 1] }
					return nil
				}
				
				// if card isn't yet selected (select its stack)
				// or if cards above it are selected (deselect the cards above)
				if !cardView.isSelected || (oneCardUp != nil && oneCardUp!.isSelected) {
					
					clearSelectedStack()
					
					// Representation of stack in View (assemble, select)
					// the argument in suffix(_:) is the length of the suffix.
					cardViewStack = boardForView[column].suffix(stackLength)
					cardViewStack.forEach({ $0.isSelected = true })
					
					selectedStack = SelectedStack(startingAt: (column, row), length: stackLength)

					print("stack starting at (\(column),\(row)), length: \(stackLength)")
					print(stackModelDescription(stack: selectedStack!))

				}
				else {
					clearSelectedStack()
					print("Selected stack cleared")
				}
			}
		}
		
		//	If it's not in a column, look for it in a cell
		
		//	If it's not in a cell, look for it in a suit stack
		
	}
	
	func newSelectionIsInSameColumnAsLastSelection(newCard: PlayingCardView) -> Bool {
		// Get column of currently selected card
		var currentColumn: Int?
		if let topSelectedCard = cardViewStack.first {
			for column in 0...(boardForView.count - 1) {
				if boardForView[column].contains(topSelectedCard) {
					currentColumn = column
				}
			}
		}
		//Check if the new card is in currentColumn
		if let col = currentColumn {
			if boardForView[col].contains(newCard) { return true }
		}
		return false
	}
	
	func selectStackOrTryMove(_ sender: UITapGestureRecognizer) {
		if let selectedCell = sender.view as? CellView {
			if let cellNum = boardView.freeCellViews.index(of: selectedCell) {
				if let stack = selectedStack {
					if stack.length == 1 && freeCellGame.cells[cellNum].isEmpty {
						// remove the card from its current spot in boardForView, and move it to the cell in freeCellGame
						boardForView[stack.col!].removeLast()
						freeCellGame.cells[cellNum].append(freeCellGame.board[stack.col!].removeLast())
						
						// move the card in the view						
						cardViewStack.last!.frame.origin = selectedCell.frame.origin
						
						clearSelectedStack()
					}
				}
			}
		}
		if let currentCard = sender.view as? PlayingCardView {
			if cardViewStack.isEmpty || newSelectionIsInSameColumnAsLastSelection(newCard:currentCard) {
				selectStack(startingWith: currentCard)
			} else {
				
			}
		}
	}
	
	func tryMove() -> Bool {
		return false
	}
	
	func playGame () {
		freeCellGame.dealCards()
		dealCards()
	}
	
	// MARK: ViewController Lifestyle
	override func viewDidAppear(_ animated: Bool) {
		boardView.freeCellViews.forEach({
			let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.selectStackOrTryMove(_:)))
			$0.isUserInteractionEnabled = true
			$0.addGestureRecognizer(singleTap)
		})
	}
}
