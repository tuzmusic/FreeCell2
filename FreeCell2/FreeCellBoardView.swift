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
	
	func yCoordinateForCardIn(_ cardType: Int, row: Int) -> CGFloat {
		return cardTypes[cardType].yMargin + spaceBetweenCards * (cardType == Location.suitStacks ? 0 : CGFloat(row))
	}
	
//	override func addSubview(_ view: UIView) {
//		addSubview(view)
//		(view as? CardView)?.position.subViewsIndex = self.subviews.index(of: view)
//	}
	
	func createEmptyCellsIn(location: Int) {
		for cell in 0 ..< cardTypes[location].count {
			
			let newCell = CardView()
			
			newCell.frame.origin = CGPoint(x: xValueForCardIn(location: location, column: cell), y: cardTypes[location].yMargin)
			newCell.frame.size = CGSize(width: cardWidth, height: cardHeight)
			newCell.backgroundColor = UIColor.clear
			addSubview(newCell)
			newCell.position = CardView.FreeCellPosition(location: location, column: cell, row: 0)		}
	}
	
	// NOTE: The difference between FreeCellVC-OLD and the newer ones with square corners is:
	// The old one drew the paths of the empty cells as part of the boardView.
	// The new ones add empty CardViews and then add PlayingCardViews on top of them.
	
	override func draw(_ rect: CGRect) {
		createEmptyCellsIn(location: Location.freeCells)
		createEmptyCellsIn(location: Location.suitStacks)
		createEmptyCellsIn(location: Location.cardColumns)
	}
}
