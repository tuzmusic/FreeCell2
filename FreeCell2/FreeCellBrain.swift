//
//  FreeCellBrain.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

class FreeCellBrain {
	
	let deckBuilder = DeckBuilder()
	
	typealias Card = DeckBuilder.Card
	typealias Column = [Card]
	typealias CardStack = [Card]
	
	var board = [[Column]](repeatElement([Column](), count: 3))
	
	var blackSuits = [0, 0]
	var redSuits = [0, 0]
	
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
	
	// MARK: Game Functions
	
	func moveCard(from source: Position, to dest: Position) {
		let card = board[source.location][source.column].remove(at: source.row)
		board[dest.location][dest.column].append(card)
		if dest.location == Location.suitStacks {
			updateSuits(for: board[dest.location][dest.column].last!)
		}
	}
	
	func updateSuits(for card: Card) {
		if card.color == .Red {
			let redUpdate = card.rank.rawValue == (redSuits[0] + 1) ? 0 : 1
			redSuits[redUpdate] += 1
		} else {
			let blackUpdate = card.rank.rawValue == (blackSuits[0] + 1) ? 0 : 1
			blackSuits[blackUpdate] += 1
		}
	}
	
	func cardToMoveToSuitStack() -> (cardPosition: Position, stackIndex: Int)? {
		for (sourceLocIndex, sourceLocation) in board.enumerated() where sourceLocIndex != 1 {
			for (sourceColIndex, sourceColumn) in sourceLocation.enumerated() {
				if let cardToMove = sourceColumn.last {
					for (suitIndex, suitStack) in board[Location.suitStacks].enumerated() {
						if shouldMove(cardToMove, to: suitStack) {
							return (Position(location: sourceLocIndex, column: sourceColIndex, row: sourceColumn.count-1), suitIndex)
						}
					}
				}
			}
		}
		return nil
	}

	func positionForCardWith(description: String) -> Position? {
		for (locIndex, location) in board.enumerated() {
			for (colIndex, column) in location.enumerated() {
				for (rowIndex, row) in column.enumerated() {
					if row.description == description {
						return Position(location: locIndex, column: colIndex, row: rowIndex)
					}
				}
			}
		}
		return nil
	}
	
	func cardAt(position: Position) -> Card? {
		if position.location < board.count
		&& position.column < board[position.location].count
		&& position.row < board[position.location][position.column].count {
			return board[position.location][position.column][position.row]
		}
		return nil
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
		if canMove(card, toSuitStack: suitStack) {
			if (card.color == .Red && card.rank.rawValue <= blackSuits.min()! + 2) ||
				(card.color == .Black && card.rank.rawValue <= redSuits.min()! + 2) {
				return true
			}
		}
		return false
	}
	
	var lastSourceTried, lastDestTried : Card!
	
	func noMovesLeft () -> Bool {
		// Are there any cells free?
		for cell in board[Location.freeCells] {
			if cell.isEmpty { return false }
		}
		// Can any cards, in any location, be moved somewhere?
		for sourceColumn in Array(board[Location.freeCells] + board[Location.cardColumns]) {
			if let bottomCard = sourceColumn.last {
				// Can any cards be moved to another column?
				for destColumn in board[Location.cardColumns] {
					if canMove([bottomCard], toColumn: destColumn) {
//						if let destCard = destColumn.last {
//							if destCard == lastSourceTried && bottomCard == lastDestTried { return true }
//						}
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
