//
//  CardView.swift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
class CardView: UIView {

	var position: Position!
	
	override func draw(_ rect: CGRect) {		
		layer.borderWidth = 1
		layer.cornerRadius = 10.0
		clipsToBounds = true
	}
}

