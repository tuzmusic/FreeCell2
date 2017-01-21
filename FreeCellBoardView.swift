//
//  FreeCellBoardView.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/9/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
//@IBDesignable
class FreeCellBoardView: UIView {
	
	var cardWidth: CGFloat { return bounds.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var cardSize: CGSize { return CGSize(width: cardWidth, height: cardHeight) }
	
	var columnsInset: CGFloat {
		return (bounds.width - (cardWidth * 8 + spaceBetweenColumns * 7)) / 2
	}
	var spaceBetweenStackedCards: CGFloat { return cardHeight / 5 }
	
	var cellsInset: CGFloat { return cardWidth / 2 }
	var stacksInset: CGFloat { return bounds.maxX - (cellsInset + (cardWidth*4) + (spaceBetweenStacks * 3)) }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var spaceBetweenStacks: CGFloat { return cardWidth / 4 }
	var verticalInsetForStacks: CGFloat { return cardHeight / 2 }
	var verticalInsetForColumns: CGFloat { return verticalInsetForStacks * 2.5 + cardHeight }
	
	var freeCellViews = [CellView]()
	
	func pathsForCells() -> [UIBezierPath] {
		var cellPaths = [UIBezierPath]()
		for cell in 1...4 {
			let newCell = CellView()
			
			var cardRect = CGRect()
			cardRect.origin.x = cellsInset + (cardWidth + spaceBetweenStacks) * CGFloat(cell - 1)
			cardRect.origin.y = verticalInsetForStacks
			cardRect.size = cardSize
			newCell.frame = cardRect
			newCell.alpha = 0.1
			
			addSubview(newCell)
			freeCellViews.append(newCell)
			cellPaths.append(UIBezierPath(roundedRect: cardRect, cornerRadius: 5))
		}
		return cellPaths
	}
	
	func pathsForSuitStacks() -> [UIBezierPath] {
		var cellPaths = [UIBezierPath]()
		for cell in 1...4 {
			var cardRect = CGRect()
			cardRect.origin.x = stacksInset + (cardWidth + spaceBetweenStacks) * CGFloat(cell - 1)
			cardRect.origin.y = verticalInsetForStacks
			cardRect.size = cardSize
			cellPaths.append(UIBezierPath(roundedRect: cardRect, cornerRadius: 5))
		}
		return cellPaths
	}
	
	func pathsForAllColumns() -> [UIBezierPath] {
		var colPaths = [UIBezierPath]()
		for column in 1...8 {
			var cardRect = CGRect()
			cardRect.origin.x = columnsInset + (cardWidth + spaceBetweenColumns) * CGFloat(column - 1)
			cardRect.origin.y = verticalInsetForColumns
			cardRect.size = cardSize
			colPaths.append(UIBezierPath(roundedRect: cardRect, cornerRadius: 5))
		}
		return colPaths
	}
	
	override func draw(_ rect: CGRect) {
		pathsForCells().forEach({ $0.stroke() })
		pathsForSuitStacks().forEach({ $0.stroke() })
		pathsForAllColumns().forEach({ $0.stroke() })
	}
	
}
