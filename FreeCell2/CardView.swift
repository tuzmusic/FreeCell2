//
//  CardView.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class CardView: UIView {

	var cardWidth: CGFloat { return superview!.bounds.size.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var cardSize: CGSize { return CGSize(width: cardWidth, height: cardHeight) }

	override func draw(_ rect: CGRect) {

		let cardRect = CGRect(origin: bounds.origin, size: cardSize)
		let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 10.0)
		
		UIColor.black.setStroke()
		UIColor.white.setFill()
		cardPath.lineWidth = 1.5
		cardPath.stroke()
	}
	
}

