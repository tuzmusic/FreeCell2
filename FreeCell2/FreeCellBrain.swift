//
//  FreeCellBrain.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

// 5/22/18 - almost done. just can't figure out how to get rid of "position(for:)" although I swear I had before!!!

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
	
	func area(for column: Int) -> Area? {
		var highCol = 0
		for (area, lastCol) in Brain.columnCounts.enumerated() {
			highCol += lastCol
			if column < highCol{
				return Area(rawValue: area)
			}
		}
		return nil
	}
	
	func moveCard(from source: Position, to dest: Position) {
		let card = board[source.column].remove(at: source.row)
		board[dest.column].append(card)
		if area(for: dest.column) == .suitStacks {
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
		for (col, sourceCol) in board.enumerated() { // For every column that's not in a suitStack
			if let cardToMove = sourceCol.last { // If there's a card in the column
				for (suitIndex, suit) in suitStacks.enumerated() { // Check every suit stack
					if shouldMove(cardToMove, to: suit) { // And if the last card in the column should be moved
						let position = Position(column: col, row: sourceCol.count-1)
						return (position, suitIndex + 4) // Return its position
					}
				}
			}
		}
		return nil
	}
	
	func position(for card: Card) -> Position? {
		// called only from shoudMove(card:to:). Can't figure out how to remove it yet!
		let desc = card.description
		for (colIndex, column) in board.enumerated() {
			for (rowIndex, cardInRow) in column.enumerated() {
				if cardInRow.description == desc {
					return Position(column: colIndex, row: rowIndex)
				}
			}
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
	
	func canMove (_ card: Card, toStack suitStack: Column) -> Bool {
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
		// called only from cardToMoveToSuitStack(), but it's worth having separate
		if canMove(card, toStack: suitStack) {
			if let column = position(for: card)?.column {
				// I thought I could eliminate checking that it's not in suitstacks, and hence eliminate the need for the column and hence delete position(for:) but that doesn't seem to work. I'm pretty sure I was able to get rid of position(for:) last time, but I can't figure it out here yet!!!
				if area(for: column) != .suitStacks &&
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
		for (col, cell) in board.enumerated() where area(for: col) == .freeCells {
			if cell.isEmpty { return false }
		}
		// Can any cards, in any location, be moved somewhere?
		for (col, sourceCol) in board.enumerated() where area(for: col) != .suitStacks {
			if let bottomCard = sourceCol.last {
				// Can any cards be moved to another column?
				for (col, destCol) in board.enumerated() where area(for: col) == .cardColumns {
					if canMove([bottomCard], toColumn: destCol) { return false }
				}
				//Can any cards be moved to a suit stack?
				for (col, suitStack) in board.enumerated() where area(for: col) == .suitStacks {
					if canMove(bottomCard, toStack: suitStack) {
						return false
					}
				}
			}
		}
		
		return true
	}
	
	func gameIsWon () -> Bool {
				
		for (col, suit) in board.enumerated() where area(for: col) == .suitStacks {
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

