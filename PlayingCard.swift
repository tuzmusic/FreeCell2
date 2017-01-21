////
////  PlayingCardView.swift
////  FreeCell
////
////  Created by Jonathan Tuzman on 1/8/17.
////  Copyright © 2017 Jonathan Tuzman. All rights reserved.
////
//
//import UIKit
//@IBDesignable
//class PlayingCard: UIButton {
//
//	func pathForCard(at position: (Int, Int)) -> UIBezierPath {
//		let (column, row) = position
//		let startingX = columnsInset + (cardWidth + spaceBetweenColumns) * CGFloat(column - 1)
//		let cardRect = CGRect(x: startingX, y: verticalInsetForColumns, width: cardWidth, height: cardHeight)
//		return UIBezierPath(roundedRect: cardRect, cornerRadius: 10.0)
//	}
//	
//		
//	var position: (Int, Int) = (0,0)
//	var cardWidth: CGFloat { return superview!.bounds.size.width / 10.0 }
//	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
//	var columnsInset: CGFloat { return cardWidth / 2 }
//	
//	var stacksInset: CGFloat { return cardWidth / 5 }
//	var spaceBetweenColumns: CGFloat { return cardWidth / 7 }
//	var spaceBetweenStacks: CGFloat { return cardWidth * 3/5 }
//	var verticalInsetForStacks: CGFloat { return cardHeight / 3 }
//	var verticalInsetForColumns: CGFloat { return verticalInsetForStacks * 2 + cardHeight }
//	
//	override func draw(_ rect: CGRect) {
//		//let card = pathForCardIn(column: 1)
//		UIColor.black.setStroke()
//		UIColor.blue.setFill()
//		//card.stroke()
//	}
//	
//}
