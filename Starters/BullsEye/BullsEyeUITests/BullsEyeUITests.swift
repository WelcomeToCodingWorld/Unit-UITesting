//
//  BullsEyeUITests.swift
//  BullsEyeUITests
//
//  Created by ari 李 on 03/12/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import XCTest

class BullsEyeUITests: XCTestCase {
    
    var app : XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGameStyleSwitch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let slideButton = app.segmentedControls/*@START_MENU_TOKEN@*/.buttons["Slide"]/*[[".segmentedControls.buttons[\"Slide\"]",".buttons[\"Slide\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let slideLable = app.staticTexts["Get as close as you can to: "]
        
        let typeButton = app/*@START_MENU_TOKEN@*/.segmentedControls.buttons["Type"]/*[[".segmentedControls.buttons[\"Type\"]",".buttons[\"Type\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        let typeLable = app.staticTexts["Guess where the slider is: "]
        if slideButton.isSelected {
            XCTAssertTrue(slideLable.exists)
            XCTAssertFalse(typeLable.exists)
            
            typeButton.tap()
            XCTAssertTrue(typeLable.exists)
            XCTAssertFalse(slideLable.exists)
        }else if typeButton.isSelected {
            XCTAssertTrue(typeLable.exists)
            XCTAssertFalse(slideLable.exists)
            
            slideButton.tap()
            XCTAssertTrue(slideLable.exists)
            XCTAssertFalse(typeLable.exists)
        }
        
        
    }
    
}
