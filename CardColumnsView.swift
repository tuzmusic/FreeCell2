//
//  CardColumnsView.swift
//  FreeCell
//
//  Created by Jonathan Tuzman on 1/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

@IBDesignable
class CardColumnsView: UIView {

	@IBInspectable var columnType: ColumnTypes = ColumnTypes.Column
	@IBInspectable var numberOfColumns: Int = 4
	
	var cardWidth: CGFloat { return window!.frame.width / 11.5 }
	var spaceBetweenColumns: CGFloat { return cardWidth / 3 }
	var columnWidth: CGFloat { return cardWidth + spaceBetweenColumns }
	var cardHeight: CGFloat { return cardWidth * (3.5/2.5) }
	var cardSize: CGSize { return CGSize(width: cardWidth, height: cardHeight) }
	var columnCardVerticalSpace: CGFloat { return cardHeight / 5 }
	var horizMargin: CGFloat { return (bounds.width - (columnWidth * CGFloat(numberOfColumns) - spaceBetweenColumns)) / 2 }
	var verticalMargin: CGFloat {
		return self.columnType == .Column ? cardHeight / 4 : (bounds.height - cardHeight) / 2 }
	
	override func draw(_ rect: CGRect) {
		
		for column in 0..<numberOfColumns {
			let newView = PlayingCardView()
			newView.tag = column
			newView.frame.origin.y = verticalMargin
			newView.frame.origin.x = horizMargin + columnWidth * CGFloat(column)
			newView.frame.size.width = cardWidth
			newView.frame.size.height = cardHeight
			newView.backgroundColor = UIColor.clear
			addSubview(newView)
		}
	}
	
	enum ColumnTypes {
		case Single
		case Stack
		case Column
	}

}
