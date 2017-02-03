//
//  ViewController.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

// TODO:
// shouldMoveTo(suitStack), at least for just the one next one
// Animation

class FreeCellViewController: UIViewController {
	
//	typealias Position = CardView.Position
	
	// MARK: Model
	var game = FreeCellBrain() // old model (still used for rules, no?)
	
	var startOfSelection: Position? {
		didSet { // this simply deals with selecting or de-selecting the views
			let newSelection = startOfSelection
			let selection = newSelection == nil ? oldValue : newSelection
			
			if let selection = selection {
				let start = selection
				for view in boardView.subviews
					where view is PlayingCardView && (view as! PlayingCardView).position.location == start.location
						&& (view as! PlayingCardView).position.column == start.column
						&& (view as! PlayingCardView).position.row >= start.row {
							(view as? PlayingCardView)?.isSelected = (newSelection == nil ? false : true)
				}
			}
		}
	}
	
	var selectedCard: FreeCellBrain.Card? {
		if let selection = startOfSelection {
			return game.board[selection.location][selection.column][selection.row]
		}
		return nil
	}
	
	func stackLength (for selection: Position?) -> Int? {
		if let selection = selection {
			return selection.location == Location.cardColumns ? game.board[Location.cardColumns][selection.column].count - selection.row : 1
		}
		return nil
	}
	
	var lastClickedView: UIView?
	var clickedColumn: FreeCellBrain.Column? {
		if let view = lastClickedView {
			return game.board[(view as? CardView)!.position.location][(view as? CardView)!.position.column]
		}
		return nil
	}
	
	@IBOutlet var boardView: FreeCellBoardView!
	@IBAction func redrawBoard(_ sender: UIButton) { updateBoardUI() }
	@IBAction func restartGame(_ sender: UIButton) { startGame() }
	@IBOutlet weak var restartButton: UIButton!
	@IBOutlet weak var redrawButton: UIButton!
	
	//MARK: Gameplay Utility Functions
	
	func moveSelection(to dest: Position) {
		if let source = startOfSelection {

			// Move cards in the model.
			game.moveCards(from: source, to: dest)
			
			// Move card in the view (Current implementation erases and redraws the entire columns.)
			for position in [source, dest] {
				// Remove all PlayingCardViews from column
				for view in boardView.subviews
					where (view as? PlayingCardView)?.position.location == position.location
						&& (view as? PlayingCardView)?.position.column == position.column {
							view.removeFromSuperview()
				}
				// Redraw the column
				for (row, card) in game.board[position.location][position.column].enumerated() {
					let newPosition = Position(location: position.location, column: position.column, row: row)
					let newCard = draw(card: card, at: newPosition)
					boardView.addSubview(newCard)
				}
			}
			startOfSelection = nil
			postMoveCleanUp()
		}
	}
	
	func postMoveCleanUp() { // print("cleanup")
		
		if let autoMove = game.cardToMoveToSuitStack() {
			startOfSelection = autoMove.cardPosition
			let suitStack = Position(location: Location.suitStacks, column: autoMove.stackIndex, row: game.board[1][autoMove.stackIndex].count-1)
			moveSelection(to: suitStack)
		}
		
		// Auto-move any cards to suitStack (to be replaced by a function in the model, although the card will still need to be moved in the view)
//		var sourceLocIndex = 0
//		for sourceLocation in [game.board[Location.freeCells], game.board[Location.cardColumns]] {
//			for (sourceColIndex, sourceColumn) in sourceLocation.enumerated() {
//				if let autoMovingCard = sourceColumn.last {
//					let sourcePosition = Position(location: sourceLocIndex, column: sourceColIndex, row: sourceColumn.count-1)
//					
//					for (suitIndex, suitStack) in game.board[Location.suitStacks].enumerated() {
//						if game.canMove(autoMovingCard, toSuitStack: suitStack) {
//							
//							// Get suitStack info (only run this check if we can move the card to the a stack. No need to do it for every card.
//							var redSuits = [0, 0]; var blackSuits = [0, 0]
//							for suitStack in game.board[Location.suitStacks] {
//								if let topOfStack = suitStack.last {
//									if topOfStack.color == .Red {
//										if redSuits[0] == 0 { redSuits[0] = topOfStack.rank.rawValue }
//										else { redSuits[1] = topOfStack.rank.rawValue }
//									}
//									if topOfStack.color == .Black {
//										if blackSuits[0] == 0 { redSuits[0] = topOfStack.rank.rawValue }
//										else { blackSuits[1] = topOfStack.rank.rawValue }
//									}
//								}
//							}
//							
//							if (autoMovingCard.color == .Red && autoMovingCard.rank.rawValue <= blackSuits.min()! + 2) ||
//								(autoMovingCard.color == .Black && autoMovingCard.rank.rawValue <= redSuits.min()! + 2) {
//								print("Auto-moving \(autoMovingCard.description) to suit stack #\(suitIndex + 1)")
//								startOfSelection = sourcePosition
//								let destSuit = Position(location: Location.suitStacks, column: suitIndex, row: 0)
//								moveSelection(to: destSuit)
//								// Even when it moves the card, it still checks the rest of the suitStacks.
//								// I'm not actually clear on how to exit this loop, since moveSelection() calls postMoveCleanup.
//								// Also, something about this implementation slows down the app, one of the loops, probably, that didn't slow it down before this implementation.
//								// Hopefully, moving all these actions to different functions (mostly in the model) will solve all these issues.
//								// Hopefully...
//							}
//						}
//					}
//				}
//			}
//			sourceLocIndex = 2
//		}
//		
		if game.gameIsWon() { gameWon() }
		if game.noMovesLeft() { gameLost() }
	}
	
	func gameWon () {
		print("You won!")
	}
	
	func gameLost () {
		print("No moves left!")
	}
	
	// MARK: Gameplay action functions
	
	func cardClicked (_ clickedCard: UITapGestureRecognizer) { print("Card clicked!")
		if let clickedCardView = clickedCard.view as? PlayingCardView { lastClickedView = clickedCardView
			if startOfSelection == nil
				|| (clickedCardView.position.column == startOfSelection?.column
					&& clickedCardView.position.location == startOfSelection?.location) {
				let oldSelection = startOfSelection
				startOfSelection = nil
				if clickedCardView.position.row != oldSelection?.row {
					startOfSelection = clickedCardView.position
				}
			} else if let selection = startOfSelection {
				let movingStack = Array(game.board[selection.location][selection.column].suffix(from: selection.row))
				// See if the stack can be moved, and move it.
				if (clickedCardView.position.location == Location.cardColumns
					&& game.canMove(movingStack, toColumn: clickedColumn!))
					|| (clickedCardView.position.location == Location.suitStacks
						&& movingStack.count == 1
						&& game.canMove(selectedCard!, toSuitStack: clickedColumn!)) {
					moveSelection(to: clickedCardView.position!)
				}
			}
		}
	}
	
	func emptyCardColumnClicked (_ cell: UITapGestureRecognizer) { //print("Empty column clicked!")
		if let clickedCell = cell.view as? CardView {
			lastClickedView = clickedCell
			
			if let selection = startOfSelection {
				// Create the stack to check if it can be moved
				let movingStack = Array(game.board[selection.location][selection.column].suffix(from: selection.row))
				
				// See if the stack can be moved, and move it.
				if game.canMove(movingStack, toColumn: clickedColumn!) {
					moveSelection(to: clickedCell.position!)
				}
			}
		}
	}
	
	func cellClicked (_ cell: UITapGestureRecognizer) { //print("Cell clicked!")
		if let cellView = cell.view as? CardView { lastClickedView = cellView
			if stackLength(for: startOfSelection) == 1 {
				moveSelection(to: cellView.position)
			}
		}
	}
	
	func suitClicked (_ suit: UITapGestureRecognizer) { //print("Suit clicked!")
		if let suitView = suit.view as? CardView { lastClickedView = suitView
			if stackLength(for: startOfSelection) == 1 && game.canMove(selectedCard!, toSuitStack: clickedColumn!) {
				moveSelection(to: suitView.position)
			}
		}
	}
	
	func doubleClick (_ clickedCard: UITapGestureRecognizer) {
		if let clickedCardView = clickedCard.view as? PlayingCardView {
			startOfSelection = clickedCardView.position
			if stackLength(for: startOfSelection) == 1 {
				for (index, suit) in game.board[Location.suitStacks].enumerated() {
					if game.canMove(selectedCard!, toSuitStack: suit) {
						let destPosition = Position(location: Location.suitStacks, column: index, row: 0)
						moveSelection(to: destPosition)
						return
					}
				}
				for (index, cell) in game.board[Location.freeCells].enumerated() {
					if cell.isEmpty {
						let destPosition = Position(location: Location.freeCells, column: index, row: 0)
						moveSelection(to: destPosition)
						return
					}
				}
				
			}
		}
	}
	
	// MARK: Setup functions
	
	func draw (card: FreeCellBrain.Card, at boardPosition: Position) -> PlayingCardView {
		let newCardView = PlayingCardView()
		
		newCardView.frame.origin.x = boardView.xValueForCardIn(location: boardPosition.location, column: boardPosition.column)
		newCardView.frame.origin.y = boardView.yCoordinateForCardIn(boardPosition.location, row: boardPosition.row)
		newCardView.frame.size = boardView.cardSize
		
		newCardView.backgroundColor = UIColor.white
		newCardView.cardColor = card.color == DeckBuilder.Color.Red ? UIColor.red : UIColor.black
		newCardView.cardDescription = card.description
		newCardView.position = boardPosition
		let cardClicked = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cardClicked(_:)))
		cardClicked.numberOfTapsRequired = 1
		newCardView.addGestureRecognizer(cardClicked)
		
		let doubleClick = UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.doubleClick(_:)))
		doubleClick.numberOfTapsRequired = 2
		newCardView.addGestureRecognizer(doubleClick)
		
		return newCardView
	}
	
	func updateBoardUI () {
		startOfSelection = nil
		
		boardView.subviews.forEach { if $0 is PlayingCardView { $0.removeFromSuperview() } }
		
		for (locIndex, location) in game.board.enumerated() {
			for (colIndex, column) in location.enumerated() {
				for (rowIndex, card) in column.enumerated() {
					let newCardPosition = Position(location: locIndex, column: colIndex, row: rowIndex)
					let newCardView = draw(card: card, at: newCardPosition)
					boardView.addSubview(newCardView)
				}
			}
		}
		addGestureRecognizers()
	}
	
	func addGestureRecognizers () {
		for view in boardView.subviews {
			if !(view is PlayingCardView) {
				if let cardView = view as? CardView {
					switch cardView.position.location {
					case Location.freeCells:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.cellClicked(_:))))
					case Location.suitStacks:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.suitClicked(_:))))
					case Location.cardColumns:
						cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FreeCellViewController.emptyCardColumnClicked(_:))))
					default: break
					}
				}
			}
		}
	}
	
	func startGame () {
		startOfSelection = nil
		game.createBoard()
		game.dealCards()
		updateBoardUI()
		postMoveCleanUp()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//		game.board[0][0].append(FreeCellBrain.Card(rank: .Two, suit: .Spades))
		//		game.board[1][0].append(FreeCellBrain.Card(rank: .Ace, suit: .Spades))
		//				game.board[2][2].removeAll()
		startGame()
	}
}


