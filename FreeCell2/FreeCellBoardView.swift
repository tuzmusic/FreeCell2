//
//  FreeCellswift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class FreeCellBoardView: UIView {
	
	@IBInspectable let numberOfColumns = 8
	@IBInspectable let numberOfCells = 4
	@IBInspectable let numberOfSuits = 4

	var cardWidth: CGFloat { return window!.frame.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var columnWidth: CGFloat { return cardWidth + spaceBetweenColumns }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var columnsHorizMargins: CGFloat { return (bounds.width - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2 }
	var suitsHorizMargin: CGFloat {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells + numberOfSuits)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells + numberOfSuits - 2)
		return startingPointForCells.x + (totalCardsSpace + totalColumnSpace) + cellsAndSuitsVerticalMargin * 2
	}
	var cellsHorizMargins: CGFloat {
		let totalCardsSpace = cardWidth * CGFloat(numberOfCells + numberOfSuits)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(numberOfCells + numberOfSuits - 2)
		return (totalCardsSpace + totalColumnSpace) / 4
	}
	var cellsAndSuitsVerticalMargin: CGFloat { return cardHeight / 2 }
	
	var spaceBetweenCards: CGFloat { return cardHeight / 5 }
	
	var startingPointForCells: CGPoint {
		return CGPoint(x: cellsHorizMargins, y: cellsAndSuitsVerticalMargin)
	}
	var startingPointForSuits: CGPoint {
		return CGPoint(x: suitsHorizMargin, y: cellsAndSuitsVerticalMargin)
	}
	
	var startingPointForColumns: CGPoint {
		return CGPoint(x: columnsHorizMargins, y: cellsAndSuitsVerticalMargin + cardHeight * 1.5)
	}
	
	func createCardCells(number: Int, at startingPoint: CGPoint) {
		for cell in 0 ..< number {
			let newCell = CardView()
			
			newCell.frame.origin.x = startingPoint.x + (cardWidth + spaceBetweenColumns) * CGFloat(cell)
			newCell.frame.origin.y = startingPoint.y
			newCell.frame.size = CGSize(width: cardWidth, height: cardHeight)
			
			newCell.backgroundColor = UIColor.clear
			newCell.tag = number
			
			addSubview(newCell)
		}
	}
	
	override func draw(_ rect: CGRect) {
		createCardCells(number: numberOfCells, at: startingPointForCells)
		createCardCells(number: numberOfSuits, at: startingPointForCells)
		createCardCells(number: numberOfColumns, at: startingPointForCells)
	}
	
}
