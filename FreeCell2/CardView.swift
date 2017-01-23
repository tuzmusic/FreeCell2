//
//  CardView.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class CardView: UIView {

	var cardWidth: CGFloat { return window!.frame.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var cardSize: CGSize { return CGSize(width: cardWidth, height: cardHeight) }
	var position: FreeCellPosition!
	
	struct FreeCellPosition {
		var column, row, subViewsIndex: Int
		var location: FreeCellCardType
	}
	
	enum FreeCellCardType {
		case freeCell, suitStack, cardColumn
	}
	
	override func draw(_ rect: CGRect) {

		let cardRect = CGRect(origin: bounds.origin, size: cardSize)
		let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 10.0)
		
		UIColor.black.setStroke()
		cardPath.lineWidth = 2
		cardPath.stroke()
	}
}

