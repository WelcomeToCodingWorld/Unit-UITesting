//
//  BullsEyeTests.swift
//  BullsEyeTests
//
//  Created by ari 李 on 03/12/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import XCTest
@testable import BullsEye
class BullsEyeTests: XCTestCase {
    var gameUnderTest : BullsEyeGame!
    
    // call before each test method in a test case is called
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gameUnderTest = BullsEyeGame()
        gameUnderTest.startNewGame()
    }
    
    // Provides an opportunity to customize initial state before a test case begins.
    override class func setUp() {
        super.setUp()
    }
    
    // call after each test method in a test case ends
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        gameUnderTest = nil
        super.tearDown()
    }
    
    // Provides an opportunity to perform cleanup after a test case ends.
    override class func tearDown() {
        super.tearDown()
    }
    
    func testScoreIsComputed() {
        let guess = gameUnderTest.targetValue - 5
        gameUnderTest.check(guess: guess)
        XCTAssertLessThanOrEqual(gameUnderTest.scoreRound, 95, "Score computed from guess is wrong")
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
