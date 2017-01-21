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
	
	var cardWidth: CGFloat { return window!.frame.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var columnWidth: CGFloat { return cardWidth + spaceBetweenColumns }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var columnsHorizMargins: CGFloat { return (bounds.width - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2 }
	var columnsVerticalMargin: CGFloat { return cellsAndSuitsVerticalMargin + cardHeight * 1.3 }
	
	var cellsHorizMargins: CGFloat { return cardWidth / 4 }
	var suitsHorizMargin: CGFloat {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return bounds.maxX - cellsHorizMargins - (totalCardsSpace + totalColumnSpace)
	}
	var cellsAndSuitsVerticalMargin: CGFloat { return cardHeight / 3 }
	
	var spaceBetweenCards: CGFloat { return cardHeight / 5 }
	
	var startingPointForCells: CGPoint {
		return CGPoint(x: cellsHorizMargins, y: cellsAndSuitsVerticalMargin)
	}
	var startingPointForSuits: CGPoint {
		return CGPoint(x: suitsHorizMargin, y: cellsAndSuitsVerticalMargin)
	}
		
	struct CardType {
		var count: Int
		var xMargin: CGFloat
	}
	
	var freeCell: CardType {
		return CardType(count: numberOfCells,
		                xMargin: cardWidth / 4) }
	
	var suitStack: CardType {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells - 1)
		return CardType(count: numberOfSuits,
		                xMargin: bounds.maxX - cellsHorizMargins - (totalCardsSpace + totalColumnSpace)) }
	
	var cardColumn: CardType {
		return CardType(count: numberOfColumns,
		                xMargin: (bounds.width - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2) }
	
	func xValueFor(cellNumber: Int) -> CGFloat {
		return cellsHorizMargins + spaceBetweenColumns * CGFloat(cellNumber)
	}
	
	func xValueFor(suitNumber: Int) -> CGFloat {
		return suitsHorizMargin + spaceBetweenColumns * CGFloat(suitNumber)
	}
	
	var startingPointForColumns: CGPoint {
		return CGPoint(x: columnsHorizMargins, y: columnsVerticalMargin)
	}
	
	func xCoordinateForCardIn(column: Int) -> CGFloat {
		return columnsHorizMargins + (cardWidth + spaceBetweenColumns) * CGFloat(column)
	}
	
	func yCoordinateForCardIn(row: Int) -> CGFloat {
		return columnsVerticalMargin + spaceBetweenCards * CGFloat(row)
	}
	
	func createCellsOf(type: CardView.FreeCellColumnType, number: Int, at startingPoint: CGPoint) {
		for cell in 0 ..< number {
			let newCell = CardView()
			
			newCell.frame.origin.x = startingPoint.x + (cardWidth + spaceBetweenColumns) * CGFloat(cell)
			newCell.frame.origin.y = startingPoint.y
			newCell.frame.size = CGSize(width: cardWidth, height: cardHeight)
			
			newCell.backgroundColor = UIColor.clear
			newCell.tag = number
			newCell.freeCellType = type
			
			addSubview(newCell)
		}
	}
	
	override func draw(_ rect: CGRect) {
		createCellsOf(type: .FreeCell, number: numberOfCells, at: startingPointForCells)
		createCellsOf(type: .SuitStack, number: numberOfSuits, at: startingPointForSuits)
		createCellsOf(type: .CardColumn, number: numberOfColumns, at: startingPointForColumns)
	}
	
}
