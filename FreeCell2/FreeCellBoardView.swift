//
//  FreeCellswift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
@IBDesignable
class FreeCellBoardView: UIView {
	
	@IBInspectable var numberOfColumns = 8 { didSet { setNeedsDisplay() } }
	@IBInspectable var numberOfCells = 4 { didSet { setNeedsDisplay() } }
	@IBInspectable var numberOfSuits = 4 { didSet { setNeedsDisplay() } }
	
	var cardWidth: CGFloat { return bounds.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var cardSize: CGSize { return CGSize(width: cardWidth, height: cardHeight) }
	var columnWidth: CGFloat { return cardWidth + spaceBetweenColumns }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var spaceBetweenCards: CGFloat { return cardHeight / 5 }
	
	struct CardType {
		var count: Int
		var xMargin: CGFloat
		var yMargin: CGFloat
	}
	
	var cardTypes: [CardType] { return [ freeCell, suitStack, cardColumn] }
	
	var freeCell: CardType {
		return CardType(count: numberOfCells,
		                xMargin: cardWidth / 3,
		                yMargin: cardHeight / 3)
	}
	
	var suitStack: CardType {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return CardType(count: numberOfSuits,
		                xMargin: bounds.maxX - freeCell.xMargin - (totalCardsSpace + totalColumnSpace),
		                yMargin: freeCell.yMargin)
	}
	
	var cardColumn: CardType {
		return CardType(count: numberOfColumns,
		                xMargin: (bounds.maxX - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2,
		                yMargin: freeCell.yMargin + cardHeight * 1.3)
	}
	
	func xValueForCardIn(location: Int, column: Int) -> CGFloat {
		return cardTypes[location].xMargin + (cardWidth + spaceBetweenColumns) * CGFloat(column)
	}
	
	func yCoordinateForCardIn(_ location: Int, row: Int) -> CGFloat {
		return cardTypes[location].yMargin + spaceBetweenCards * (location == Location.suitStacks ? 0 : CGFloat(row))
	}
		
	func createEmptyCellsIn(location: Int) {
		for cell in 0 ..< cardTypes[location].count {			
			
			let origin = CGPoint(x: xValueForCardIn(location: location, column: cell), y: cardTypes[location].yMargin)
			let size = CGSize(width: cardWidth, height: cardHeight)
			let newCell = CardView(frame: CGRect(origin: origin, size: size))
			newCell.backgroundColor = UIColor.clear
			addSubview(newCell)
			newCell.position = Position(column: cell, row: 0)
		}
	}
//
//	let gravity = UIGravityBehavior()
//
//	func gravityFalls () {
//		let animator = UIDynamicAnimator(referenceView: self)
//		for view in subviews where view is PlayingCardView {
//			gravity.addItem(view)
//		}
//		animator.addBehavior(gravity)
//	}

	
	override func draw(_ rect: CGRect) {
		createEmptyCellsIn(location: Location.freeCells)
		createEmptyCellsIn(location: Location.suitStacks)
		createEmptyCellsIn(location: Location.cardColumns)
	}
}
