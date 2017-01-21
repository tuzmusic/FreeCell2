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
	
	@IBOutlet var wholeTableView: FreeCellBoardView!
	
	
	// Setup functions
	func create (card: FreeCellBrain.Card, at position: (Int, Int)) -> PlayingCardView {
		let newCardView = PlayingCardView()
		let (column, row) = position
		var columns = [CardView]()
		for view in wholeTableView.subviews {
			if let col = view as? CardView {
				if col.freeCellType! == .CardColumn {
					columns.append(col)
				}
			}
		}
		
		newCardView.frame.origin.x = columns[column].frame.minX
		newCardView.frame.origin.y = wholeTableView.columnsVerticalMargin + wholeTableView.spaceBetweenCards * CGFloat(row)
		newCardView.frame.size = CGSize(width: wholeTableView.cardWidth, height: wholeTableView.cardHeight)
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
				
				//newCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:))))
				wholeTableView.addSubview(newCard)
			}
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		dealCards()
	}
	
}

