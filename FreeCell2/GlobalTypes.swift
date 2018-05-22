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

struct Position {
	var column, row: Int
}
