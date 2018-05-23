//
//  BoardAreaswift
//  FreeCell2
//
//  Created by Jonathan Tuzman on 1/26/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

enum Area: Int {
	case freeCells = 0, suitStacks, cardColumns
}

//struct Area {
//	static let freeCells = 0
//	static let suitStacks = 1
//	static let cardColumns = 2
//}

struct Position {
	var column, row: Int
}
