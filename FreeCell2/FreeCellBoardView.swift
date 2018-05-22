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
	
	struct BoardArea {
		var count: Int
		var xMargin: CGFloat
		var yMargin: CGFloat
	}
	
	var boardAreas: [BoardArea] { return [freeCell, suitStack, cardColumn] }
	
	var freeCell: BoardArea {
		return BoardArea(count: numberOfCells,
		                xMargin: cardWidth / 3,
		                yMargin: cardHeight / 3)
	}
	
	var suitStack: BoardArea {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return BoardArea(count: numberOfSuits,
		                xMargin: bounds.maxX - freeCell.xMargin - (totalCardsSpace + totalColumnSpace),
		                yMargin: freeCell.yMargin)
	}
	
	var cardColumn: BoardArea {
		return BoardArea(count: numberOfColumns,
		                xMargin: (bounds.maxX - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2,
		                yMargin: freeCell.yMargin + cardHeight * 1.3)
	}
	
	func xValueForCard(in area: Int, column: Int) -> CGFloat {
		return boardAreas[area].xMargin + (cardWidth + spaceBetweenColumns) * CGFloat(column)
	}
	
	func yCoordinateForCard(in area: Int, row: Int) -> CGFloat {
		return boardAreas[area].yMargin + spaceBetweenCards * (area == Area.suitStacks ? 0 : CGFloat(row))
	}
	
/*	func areaBoundaries(for areaIndex: Int) -> (min: Int, max: Int) {
		var first = 0 // First index at this location
		for i in 0..<areaIndex {
			first += boardAreas[i].count
		}
		let next = first + boardAreas[areaIndex].count - 1
		return (first, next)
	}
	*/
	
	func firstColumn(in area: Int) -> Int {
		var first = 0 // First index at this location
		for i in 0..<area {
			first += boardAreas[i].count
		}
		return first
	}
	
	func createEmptyCells(in area: Int) {
		for cell in 0 ..< boardAreas[area].count {
			let origin = CGPoint(x: xValueForCard(in: area, column: cell), y: boardAreas[area].yMargin)
			let size = CGSize(width: cardWidth, height: cardHeight)
			let newCell = CardView(frame: CGRect(origin: origin, size: size))
			newCell.backgroundColor = UIColor.clear
			addSubview(newCell)
			let col = firstColumn(in: area) + cell
			newCell.position = Position(column: col, row: 0)
		}
	}
	
	override func draw(_ rect: CGRect) {
		createEmptyCells(in: Area.freeCells)
		createEmptyCells(in: Area.suitStacks)
		createEmptyCells(in: Area.cardColumns)
	}
}
