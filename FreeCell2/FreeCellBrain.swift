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
	
	var board = [[Column]](repeatElement([Column](), count: 3))
	
	init () {
		createBoard()
		dealCards()
	}
	
	func createBoard () {
		board[Location.freeCells] = [Column](repeating: Column(), count: 4)
		board[Location.suitStacks] = [Column](repeating: Column(), count: 4)
		board[Location.cardColumns] = [Column](repeating: Column(), count: 8)
	}
	
	// Deal cards - remove them from the top of deck and add them to the board
	func dealCards () {
		var deck = deckBuilder.buildDeck().shuffled()
		while deck.count > 0 {
			for column in 0 ..< board[Location.cardColumns].count {
				if deck.count > 0 {
					board[Location.cardColumns][column].append(deck.removeFirst())
				}
			}
		}
	}
	
	
	// MARK: Game Rules
	
	var numberOfCardsThatCanBeMoved: Int {
		// TODO: IMPORTANT: This doesn't take into account if the destination column is an empty column.
		// If the destination is an empty column, it needs to not be counted as empty!
		var emptyCells = 0
		for column in board[Location.freeCells] {
			if column.isEmpty {
				emptyCells += 1
			}
		}
		var freeColumns = 0
		for column in board[Location.cardColumns] {
			if column.isEmpty {
				freeColumns += 1
			}
		}
		return (emptyCells + 1) * (freeColumns + 1)
	}
	
	// the __Move functions probably need to be rewritten to use Positions rather than stacks. 
	// although Position is a cardView thing so it's probably the implementation of these in the controller that need to "create" stacks from Position data to pass as arguments.
	// Maybe. Or something.
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
	
	func noMovesLeft () -> Bool {
		// Are there any cells free?
		//for cell in freeCells  {
		for cell in board[Location.freeCells] {
			if cell.isEmpty { return false }
		}
		for sourceColumn in board[Location.cardColumns] {
			if let bottomCard = sourceColumn.last {
				//Can any cards be moved to another column?
				for destColumn in board[Location.cardColumns] {
					if canMove([bottomCard], to: destColumn) {
						return false
					}
				}
				//Can any cards be moved to a suit stack?
				for suitStack in board[Location.suitStacks] {
					if canMove(bottomCard, to: suitStack) {
						return false
					}
				}
			}
		}
		
		return true
	}
	
	func gameIsWon () -> Bool {
		for suit in board[Location.suitStacks] {
			if suit.count < 13 {
				return false
			}
		}
		return true
	}
}

// Deck shuffling extensions
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
