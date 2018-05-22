//
//  FreeCellBrain.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

typealias Brain = FreeCellBrain
class FreeCellBrain {
	
	let deckBuilder = DeckBuilder()
	
	typealias Card = DeckBuilder.Card
	typealias Column = [Card]
	typealias CardStack = [Card]
	
	static let numberOfCells = 4
	static let numberOfSuits = 4
	static let numberOfColumns = 8
	static var columnCounts = [numberOfCells, numberOfSuits, numberOfColumns]
	
	var board = [Column]()
	
	var freeCells: ArraySlice<Column> {
		return board.prefix(Brain.numberOfCells)
	}
	
	var suitStacks: ArraySlice<Column> {
		let topShaved = board.prefix(Brain.numberOfCells + Brain.numberOfSuits)
		return topShaved.suffix(Brain.numberOfSuits)
	}
	
	var cardColumns: ArraySlice<Column> {
		return board.suffix(Brain.numberOfColumns)
	}
	
	var blackSuits = [0, 0]
	var redSuits = [0, 0]
	
	let firstIndex: Dictionary = [
		Area.freeCells : 0, // columnCounts[location] - columnCounts[location] = 0
		Area.suitStacks : 4, // columnCounts[location - 1] + columnCounts[location] - columnCounts[location] = columnCounts(location - 1)
		Area.cardColumns : 8 ] // columnCounts[location - 1] + columnCounts[location - 2]
	
	func emptyBoard () {
		board = [Column](repeating: Column(), count: Brain.columnCounts.reduce(0, +))
	}
	
	// Deal cards - remove them from the top of deck and add them to the board
	func dealCards () {
		var deck = deckBuilder.buildDeck().shuffled()
		while deck.count > 0 {
			for index in cardColumns.indices.first! ..< board.count {
				if deck.count > 0 {
					board[index].append(deck.removeFirst())
				}
			}
		}
	}
	
	// MARK: Game Functions
	
	func area(for column: Int) -> Int? {
		var highCol = 0
		for (area, lastCol) in Brain.columnCounts.enumerated() {
			highCol += lastCol
			if column < highCol{
				return area
			}
		}
		return nil
	}
	
	func moveCard(from source: Position, to dest: Position) {
		let card = board[source.column].remove(at: source.row)
		board[dest.column].append(card)
		if area(for: dest.column) == Area.suitStacks {
			updateSuits(for: board[dest.column].last!)
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
	
	func cardToMoveToSuitStack() -> (cardOldPosition: Position, destStackIndex: Int)? {
		for sourceColumn in board { // For every column that's not in a suitStack
			if let cardToMove = sourceColumn.last { // If there's a card in the column
				for (suitIndex, suit) in suitStacks.enumerated() { // Check every suit stack
					if shouldMove(cardToMove, to: suit) { // And if the last card in the column should be moved
						if let position = positionFor(cardToMove) {
							return (position, suitIndex + 4) // Return its position
						}
					}
				}
			}
		}
		return nil
	}
	
	func positionForCardWith(description: String) -> Position? {
		for (colIndex, column) in board.enumerated() {
			for (rowIndex, cardInRow) in column.enumerated() {
				if cardInRow.description == description {
					return Position(column: colIndex, row: rowIndex)
				}
			}
		}
		return nil
	}
	
	func positionFor(_ card: Card) -> Position? {
		return positionForCardWith(description: card.description) ?? nil
	}
	
	func cardWith(description: String) -> Card? {
		if let position = positionForCardWith(description: description) {
			return board[position.column][position.row]
		}
		return nil
	}
	
	func card(at position: Position) -> Card? {
		if position.column < board.count && position.row < board[position.column].count {
			return board[position.column][position.row]
		}
		return nil
	}
	
	
	// MARK: Game Rules
	
	func canMove (_ stack: Column, toColumn column: Column) -> Bool {
		
		var emptyCells = 0
		for column in freeCells where column.isEmpty {
			emptyCells += 1
		}
		var freeColumns = 0
		for column in cardColumns where column.isEmpty {
			freeColumns += 1
		}
		if column.isEmpty { freeColumns -= 1 }
		let numberOfCardsThatCanBeMoved = (emptyCells + 1) * (1 + freeColumns)
		
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
	
	func canMove (_ card: Card, to suitStack: Column) -> Bool {
		if suitStack.isEmpty && card.rank == .Ace {
			return true
		} else if let topSuitCard = suitStack.last {
			if card.suit == topSuitCard.suit
				&& card.rank.rawValue == topSuitCard.rank.rawValue + 1 {
				return true
			}
		}
		return false
	}
	
	func shouldMove (_ card: Card, to suitStack: Column) -> Bool {
		if canMove(card, to: suitStack) {
			if let column = positionFor(card)?.column {
				if area(for: column) != Area.suitStacks &&
					((card.color == .Red && card.rank.rawValue <= blackSuits.min()! + 2) ||
						(card.color == .Black && card.rank.rawValue <= redSuits.min()! + 2)) {
					return true
				}
			}
		}
		return false
	}
	
	var lastSourceTried, lastDestTried : Card!
	
	func noMovesLeft () -> Bool {
		// Are there any cells free?
		for (colIndex, cell) in board.enumerated() where area(for: colIndex) == Area.freeCells {
			if cell.isEmpty { return false }
		}
		// Can any cards, in any location, be moved somewhere?
		for (colIndex, sourceColumn) in board.enumerated() where area(for: colIndex) != Area.suitStacks {
			if let bottomCard = sourceColumn.last {
				// Can any cards be moved to another column?
				for (colIndex, destColumn) in board.enumerated() where area(for: colIndex) == Area.cardColumns {
					if canMove([bottomCard], toColumn: destColumn) {
						//						if let destCard = destColumn.last {
						//							if destCard == lastSourceTried && bottomCard == lastDestTried { return true }
						//						}
						return false
					}
				}
				//Can any cards be moved to a suit stack?
				for (colIndex, suitStack) in board.enumerated() where area(for: colIndex) == Area.suitStacks {
					if canMove(bottomCard, to: suitStack) {
						return false
					}
				}
			}
		}
		
		return true
	}
	
	func gameIsWon () -> Bool {
				
		for (colIndex, suit) in board.enumerated() where area(for: colIndex) == Area.suitStacks {
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
			let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			guard d != 0 else { continue }
			let i = index(firstUnshuffled, offsetBy: d)
			self.swapAt(firstUnshuffled, i)
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

