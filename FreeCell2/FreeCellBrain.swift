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

	func canMove (_ stack: Column, toColumn column: Column) -> Bool {
		
		var emptyCells = 0
		for col in board[Location.freeCells] where col.isEmpty {
			emptyCells += 1
		}
		var freeColumns = 0
		for col in board[Location.cardColumns] where col.isEmpty {
			freeColumns += 1
		}
		if column.isEmpty { freeColumns -= 1 }
		let numberOfCardsThatCanBeMoved = (emptyCells + 1) * (1 + freeColumns)
		//print("\(numberOfCardsThatCanBeMoved) cards can be moved")
	
		if stack.count <= numberOfCardsThatCanBeMoved {
			if column.isEmpty {
				return true
			} else if let topCard = stack.first, let bottomCard = column.last {
				if topCard.color != bottomCard.color
					&& topCard.rank.rawValue == bottomCard.rank.rawValue - 1 {
					return true
				}
			}
		}
		return false
	}
	
	func canMove (_ card: Card, toSuitStack suitStack: Column) -> Bool {
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
		for sourceColumn in Array(board[Location.cardColumns] + board[Location.freeCells]) {
			if let bottomCard = sourceColumn.last {
				//Can any cards be moved to another column?
				for destColumn in board[Location.cardColumns] {
					if canMove([bottomCard], toColumn: destColumn) {
						return false
					}
				}
				//Can any cards be moved to a suit stack?
				for suitStack in board[Location.suitStacks] {
					if canMove(bottomCard, toSuitStack: suitStack) {
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
