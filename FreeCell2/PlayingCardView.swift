//
//  PlayingCardView.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class PlayingCardView: CardView {
	
	var isSelected = false {
		didSet {
			backgroundColor = isSelected ? UIColor.lightGray : UIColor.white
		}
	}
	
	var cardColor: UIColor?
	var cardDescription: String?
	var position: (Int, Int)?

	func addLabels() {
		
		let centerLabel = UILabel()
		centerLabel.frame = self.bounds
		centerLabel.textAlignment = NSTextAlignment.center
		centerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: 4)
		if let color = cardColor { centerLabel.textColor = color }
		centerLabel.text = cardDescription
		addSubview(centerLabel)
		
		let topLabel = UILabel()
		topLabel.frame = CGRect(x: 4, y: 3, width: cardWidth, height: cardHeight / 5.5)
		topLabel.textAlignment = NSTextAlignment.left
		topLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: 2)
		if let color = cardColor { topLabel.textColor = color }
		topLabel.text = cardDescription
		addSubview(topLabel)
		
		let bottomLabel = UILabel()
		bottomLabel.frame.size = CGSize(width: cardWidth, height: cardHeight / 5.5)
		bottomLabel.frame.origin.x = bounds.width - bottomLabel.frame.width - 4
		bottomLabel.frame.origin.y = bounds.height - bottomLabel.frame.height - 3
		bottomLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: 2)
		if let color = cardColor { bottomLabel.textColor = color }
		bottomLabel.text = cardDescription
		bottomLabel.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
		addSubview(bottomLabel)

	}
	
	override func draw(_ rect: CGRect) {
		addLabels()
	}
}
