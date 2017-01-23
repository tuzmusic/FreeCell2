//
//  FreeCellBrain.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

class FreeCellBrain {
	
	// Deck variables
	let deckBuilder = DeckBuilder()
	
	// Universe variables
	typealias Card = DeckBuilder.Card
	typealias Column = [Card]
	typealias CardStack = [Card]

	var cardColumns = [Column](repeating: [], count: 8)
	var cells = [Column](repeatElement(Column(), count: 4))
	var suitStacks = [Column](repeatElement(Column(), count: 4))

	// Deal cards - remove them from the top of deck and add them to the board
	func dealCards () {
		var deck = deckBuilder.buildDeck().shuffled()
		
		let totalCards = deck.count
		var cardCount = 0
		
		for _ in 0...6 {
			for column in 0...7 {
				if cardCount < totalCards {
					cardColumns[column].append(deck.removeFirst())
					cardCount += 1
				}
			}
		}
	}
	
	
	// MARK: Game Rules
	
	var numberOfCardsThatCanBeMoved: Int {
		// TODO: IMPORTANT: This doesn't take into account if the destination column is an empty column.
		// If the destination is an empty column, it needs to not be counted as empty!
		var freeCells = 0
		for column in cells {
			if column.isEmpty {
				freeCells += 1
			}
		}
		var freeColumns = 0
		for column in cardColumns {
			if column.isEmpty {
				freeColumns += 1
			}
		}
		return (freeCells + 1) * (freeColumns + 1)
	}
	
	func canMove (_ stack: Column, to column: Column) -> Bool {
		if let topCard = stack.first, let bottomCard = column.last {
			if stack.count <= numberOfCardsThatCanBeMoved
				&& topCard.color != bottomCard.color
				&& topCard.rank.rawValue == bottomCard.rank.rawValue - 1 {
				return true
			}
		} else if column.isEmpty {
			return true
		}
		return false
	}
	
	func canMove (_ card: Card, to suitStack: Column) -> Bool {
		if let topSuitCard = suitStack.last {
			if card.suit == topSuitCard.suit
				&& card.rank.rawValue == topSuitCard.rank.rawValue + 1 {
				return true
			}
		} else if suitStack.isEmpty && card.rank == .Ace {
			return true
		}
		return false
	}
	
	func shouldMove (_ card: Card, to suitStack: Column) -> Bool {
		// complicated rules about automatically moving cards to suit stack
		// to be called in "upkeep" phase after each move
		return false
	}
	
	func noMovesLeft (board: [Column]) -> Bool {
		// Are there any cells free?
		for cell in cells  {
			if cell.isEmpty { return false }
		}
		for sourceColumn in board {
			if let bottomCard = sourceColumn.last {
				//Can any cards be moved to another column?
				for destColumn in board {
					if canMove([bottomCard], to: destColumn) {
						return false
					}
				}
				//Can any cards be moved to a suit stack?
				for suitStack in suitStacks {
					if canMove(bottomCard, to: suitStack) {
						return false
					}
				}
			}
		}
		
		return true
	}
	
	func gameIsWon () -> Bool {
		for suit in suitStacks {
			if suit.count < 13 {
				return false
			}
		}
		return true
	}
}
extension MutableCollection where Indices.Iterator.Element == Index {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			guard d != 0 else { continue }
			let i = index(firstUnshuffled, offsetBy: d)
			swap(&self[firstUnshuffled], &self[i])
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Iterator.Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}
