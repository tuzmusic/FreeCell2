//
//  FreeCellUnitTests.swift
//  FreeCell2Tests
//
//  Created by Jonathan Tuzman on 5/22/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import XCTest
@testable import FreeCell2

class FreeCellUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAreaBoundaryFinder() {
		let board = FreeCellBoardView()
		_ = XCTAssertEqual(board.areaBoundaries(for: 0).min, 0)
		_ = XCTAssertEqual(board.areaBoundaries(for: 0).max, 3)
		_ = XCTAssertEqual(board.areaBoundaries(for: 1).min, 4)
		_ = XCTAssertEqual(board.areaBoundaries(for: 1).max, 7)
		_ = XCTAssertEqual(board.areaBoundaries(for: 2).min, 8)
		_ = XCTAssertEqual(board.areaBoundaries(for: 2).max, 15)
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
