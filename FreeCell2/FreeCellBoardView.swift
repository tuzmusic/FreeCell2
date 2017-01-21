//
//  FreeCellBoardView.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
@IBDesignable
class FreeCellBoardView: UIView {
	
	let cardView = CardView()
	
	@IBInspectable let numberOfColumns = 8
	@IBInspectable let numberOfCells = 4
	@IBInspectable let numberOfSuits = 4
	
	var cardWidth: CGFloat { return cardView.cardWidth }
	var cardHeight: CGFloat { return cardView.cardHeight }
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
	
	func paths(for cellsCount: Int, at startingPoint: CGPoint) -> [UIBezierPath] {
		var cellPaths = [UIBezierPath]()
		for cell in 0 ..< cellsCount {
			let newCell = CardView()
			
			var cardRect = CGRect()
			cardRect.origin.x = startingPoint.x + (cardWidth + spaceBetweenColumns) * CGFloat(cell)
			cardRect.origin.y = startingPoint.y
			cardRect.size = CGSize(width: cardWidth, height: cardHeight)
			newCell.frame = cardRect
			
			cellPaths.append(UIBezierPath(roundedRect: cardRect, cornerRadius: 5))
		}
		return cellPaths
	}
	
	override func draw(_ rect: CGRect) {
		UIColor.black.setStroke()
		UIColor.clear.setFill()
		
		paths(for: numberOfCells, at: startingPointForCells).forEach { $0.stroke() }
		paths(for: numberOfSuits, at: startingPointForSuits).forEach { $0.stroke() }
		paths(for: numberOfColumns, at: startingPointForColumns).forEach { $0.stroke() }
	}
 
}
