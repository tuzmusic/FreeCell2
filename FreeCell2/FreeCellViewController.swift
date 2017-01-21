//
//  ViewController.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class FreeCellViewController: UIViewController {

	let freeCellGame = FreeCellBrain()
	
	var selection: FreeCellSelection?
	
	struct FreeCellSelection {
		var column: Int
		var row: Int?
		var length: Int?
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	
	
	// Setup functions
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
		dealCards()
	}
	
}

