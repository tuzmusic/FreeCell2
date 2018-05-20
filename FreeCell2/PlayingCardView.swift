//
//  PlayingCardView.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class PlayingCardView: CardView {
	
	var cardWidth: CGFloat { return superview!.bounds.width / 11.5 }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	static var animDelay = 0.0
	static var animScale: CGFloat = 1.1
	static var animDuration: Double = 0.1
	
	var isSelected = false {
		didSet {
			let scale = PlayingCardView.animScale
			let duration = PlayingCardView.animDuration
			let delay = PlayingCardView.animDelay
			func scaleAndWiggle () {
				let rotation = CGFloat(Double.pi / 12)
				UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut,
				               animations: {
								self.transform = CGAffineTransform.identity.rotated(by: rotation)
								self.transform = self.transform.scaledBy(x:scale, y:scale)
				}) { (_) in
					UIView.animate(withDuration: duration * 0.9, delay: 0, options: .curveEaseInOut,
					               animations: {
									self.transform = CGAffineTransform.identity.rotated(by: -rotation)
									self.transform = self.transform.scaledBy(x:scale*1.1, y:scale*1.1)
					})
					{ (_) in
						UIView.animate(withDuration: duration * 1, delay: 0, options: .curveEaseInOut,
						               animations: {
										self.transform = CGAffineTransform.identity
						})
					}
				}
			}
			func scaleAnimation () {
				UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut,
				               animations: {
								self.transform = self.transform.scaledBy(x:scale, y:scale)
				}) { (_) in
					UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
						self.transform = CGAffineTransform.identity
					}, completion: {
						(_) in self.backgroundColor = self.isSelected ? UIColor.lightGray : UIColor.white
					})
				}
			}
			func wiggleAnimation () {
				let rotation = CGFloat(Double.pi / 10)
				UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut,
				               animations: {
								self.transform = CGAffineTransform.identity.rotated(by: rotation)
				}) { (_) in
					UIView.animate(withDuration: duration * 0.9, delay: 0, options: .curveLinear,
					               animations: {
									self.transform = CGAffineTransform.identity.rotated(by: -rotation)
					}, completion: { (_) in
						UIView.animate(withDuration: duration * 0.9, delay: 0, options: .curveLinear,
						               animations: {
										self.transform = CGAffineTransform.identity
						})
					})
				}
			}
			// scaleAndWiggle()
			self.backgroundColor = self.isSelected ? UIColor.lightGray : UIColor.white
		}
	}
	
	var cardColor: UIColor?
	
	var cardDescription: String? {
		didSet {
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
			bottomLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
			addSubview(bottomLabel)
			
		}
	}
}
