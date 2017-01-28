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
		var location: Int
	}
	
	var cardTypes: [CardType] { return [ freeCell, suitStack, cardColumn] }
	
	var freeCell: CardType {
		return CardType(count: numberOfCells,
		                xMargin: cardWidth / 3,
		                yMargin: cardHeight / 3,
		                location: Location.freeCells)
	}
	
	var suitStack: CardType {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return CardType(count: numberOfSuits,
		                xMargin: bounds.maxX - freeCell.xMargin - (totalCardsSpace + totalColumnSpace),
		                yMargin: freeCell.yMargin,
		                location: Location.suitStacks)
	}
	
	var cardColumn: CardType {
		return CardType(count: numberOfColumns,
		                xMargin: (bounds.maxX - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2,
		                yMargin: freeCell.yMargin + cardHeight * 1.3,
		                location: Location.cardColumns)
	}
	
	func xValueFor(_ cardType: Int, in column: Int) -> CGFloat {
		return cardTypes[cardType].xMargin + (cardWidth + spaceBetweenColumns) * CGFloat(column)
	}
	
	func yCoordinateForCardIn(_ cardType: Int, row: Int) -> CGFloat {
		return cardTypes[cardType].yMargin + spaceBetweenCards * CGFloat(row)
	}
	
	func createEmptyCellsOf(type: Int) {
		for cell in 0 ..< cardTypes[type].count {
			
			let newCell = CardView()
			
			newCell.frame.origin = CGPoint(x: xValueFor(type, in: cell), y: cardTypes[type].yMargin)
			newCell.frame.size = CGSize(width: cardWidth, height: cardHeight)
			newCell.backgroundColor = UIColor.clear
			newCell.tag = cell
			addSubview(newCell)
			newCell.position = CardView.FreeCellPosition(location: cardTypes[type].location, column: cell, row: 0,
			                                             subViewsIndex: self.subviews.index(of: newCell)!)
		}
	}
	
	// NOTE: The difference between FreeCellVC-OLD and the newer ones with square corners is:
	// The old one drew the paths of the empty cells as part of the boardView.
	// The new ones add empty CardViews and then add PlayingCardViews on top of them.
	
	override func draw(_ rect: CGRect) {
		createEmptyCellsOf(type: Location.freeCells)
		createEmptyCellsOf(type: Location.suitStacks)
		createEmptyCellsOf(type: Location.cardColumns)
	}
}
