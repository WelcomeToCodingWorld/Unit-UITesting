//
//  BullsEyeMockTests.swift
//  BullsEyeMockTests
//
//  Created by ari 李 on 03/12/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import XCTest

@testable import BullsEye

class MockUserDefaults:UserDefaults {
    var gameStyleChanged = 0
    override func set(_ value: Int, forKey defaultName: String) {
        if defaultName == "gameStyle" {
            gameStyleChanged += 1
        }
    }
    
}

class BullsEyeMockTests: XCTestCase {
    
    
    var controllerUnderTest : ViewController!
    var mockUserDefaults : MockUserDefaults!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? ViewController
        mockUserDefaults = MockUserDefaults(suiteName: "testing")
        controllerUnderTest.defaults = mockUserDefaults        
    }
    
    func testGameStyleCanBeChanged() {
        let segmentControl = UISegmentedControl()
        XCTAssertEqual(mockUserDefaults.gameStyleChanged, 0, "gameStyleChanged should be 0 before sendActions")
        segmentControl.addTarget(controllerUnderTest, action: #selector(ViewController.chooseGameStyle(_:)), for: .valueChanged)
        segmentControl.sendActions(for: .valueChanged)
        XCTAssertEqual(mockUserDefaults.gameStyleChanged, 1, "gameStyle user default wasn't changed"
                       )
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controllerUnderTest = nil
        mockUserDefaults = nil
        super.tearDown()
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
