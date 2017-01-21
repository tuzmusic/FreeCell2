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
	
	var freeCell: CardType {
		return CardType(count: numberOfCells,
		                xMargin: cardWidth / 3,
		                yMargin: cardHeight / 3) }
	
	var suitStack: CardType {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return CardType(count: numberOfSuits,
		                xMargin: bounds.maxX - freeCell.xMargin - (totalCardsSpace + totalColumnSpace),
		                yMargin: freeCell.yMargin) }
	
	var cardColumn: CardType {
		return CardType(count: numberOfColumns,
		                xMargin: (bounds.maxX - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2,
		                yMargin: freeCell.yMargin + cardHeight * 1.3) }
	
	func xValueFor(_ cardType: CardType, number: Int) -> CGFloat {
		return cardType.xMargin + (cardWidth + spaceBetweenColumns) * CGFloat(number)
	}
	
	func yCoordinateForCardIn(row: Int) -> CGFloat {
		return cardColumn.yMargin + spaceBetweenCards * CGFloat(row)
	}
	
	func createCellsOf(type: CardType) {
		for cell in 0 ..< type.count {
			
			let newCell = CardView()
			
			newCell.frame.origin = CGPoint(x: xValueFor(type, number: cell), y: type.yMargin)
			newCell.frame.size = CGSize(width: cardWidth, height: cardHeight)
			newCell.backgroundColor = UIColor.clear
			newCell.tag = cell
			
			addSubview(newCell)
		}
	}
	
	override func draw(_ rect: CGRect) {
		createCellsOf(type: freeCell)
		createCellsOf(type: suitStack)
		createCellsOf(type: cardColumn)
	}
}
