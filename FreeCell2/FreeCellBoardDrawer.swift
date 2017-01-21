//
//  FreeCellBoardView.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Foundation

class FreeCellBoardDrawer {
	
	let boardView = FreeCellBoardView()
	let cardView = CardView()
	
	var cardWidth: CGFloat { return cardView.cardWidth }
	var cardHeight: CGFloat { return cardView.cardHeight }
	var columnWidth: CGFloat { return cardWidth + spaceBetweenColumns }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var columnsHorizMargins: CGFloat { return (boardView.bounds.width - (columnWidth * CGFloat(boardView.numberOfColumns) - spaceBetweenColumns)) / 2 }
	var suitsHorizMargin: CGFloat {
		let totalCardsSpace = cardWidth * CGFloat(boardView.numberOfCells + boardView.numberOfSuits)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(boardView.numberOfCells + boardView.numberOfSuits - 2)
		return startingPointForCells.x + (totalCardsSpace + totalColumnSpace) + cellsAndSuitsVerticalMargin * 2
	}
	var cellsHorizMargins: CGFloat {
		let totalCardsSpace = cardWidth * CGFloat(boardView.numberOfCells + boardView.numberOfSuits)
		let totalColumnSpace = spaceBetweenColumns * CGFloat(boardView.numberOfCells + boardView.numberOfSuits - 2)
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

			cardView.addSubview(newCell)
		}
	}
	
//		paths(for: boardView.numberOfCells, at: startingPointForCells).forEach { $0.stroke() }
//		paths(for: boardView.numberOfSuits, at: startingPointForSuits).forEach { $0.stroke() }
//		paths(for: boardView.numberOfColumns, at: startingPointForColumns).forEach { $0.stroke() }
	}
 

