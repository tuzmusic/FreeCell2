//
//  DeckBuilder.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

class DeckBuilder {
	
	//var deck: [Array<DeckBuilder.Card>] = buildDeck()
	
	func buildDeck() -> [Card] {
		
		var deck = [Card]()
		
		func printDeckDescription () {
			for card in deck {
					print("\(card.description) ", terminator: "\0")
			}
		}
		
		for suit in [Suit.Hearts, Suit.Diamonds, Suit.Clubs, Suit.Spades] {
			for rank in 1...13 {
				if let rank = Rank(rawValue: rank) {
					deck.append(Card(rank: rank, suit: suit))
				}
			}
		}
		
		return deck
	}

	
	enum Suit: Character {
		case Hearts = "♥️"
		case Diamonds = "♦️"
		case Clubs = "♣️"
		case Spades = "♠️"
		
	}

	enum Color {
		case Red, Black
	}
	
	enum Rank: Int {
		case Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King
	}
	
	struct Card: Equatable {
		var rank: Rank
		var suit: Suit
		
		static func == (lhs: Card, rhs: Card) -> Bool {
			return lhs.description == rhs.description
		}
		
		var number: String {
			var number = ""
			if rank.rawValue > 1 && rank.rawValue < 11 {
				number = String(rank.rawValue)
			} else {
				number = String(describing: String(describing:rank).first!)
			}
			return number
		}
		
		var color: Color {
			return (suit.rawValue == "♥️" || suit.rawValue == "♦️") ? Color.Red : Color.Black
		}
		var description: String {
			return "\(number)\(suit.rawValue)"
		}
		var fullName: String {
			return "\(rank) of \(suit.rawValue)"
		}
	}
}

