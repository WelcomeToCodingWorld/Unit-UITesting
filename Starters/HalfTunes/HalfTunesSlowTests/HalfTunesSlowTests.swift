//
//  HalfTunesSlowTests.swift
//  HalfTunesSlowTests
//
//  Created by ari 李 on 03/12/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import XCTest
@testable import HalfTunes
class HalfTunesSlowTests: XCTestCase {
    var sessionUnderTest : URLSession!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sessionUnderTest = nil
        super.tearDown()
    }
    
    func testValidCallToiTunesGetHttpStatusCode200() {
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
//        let promise = XCTestExpectation(description: "Status code: 200")
        let promise = expectation(description: "Status code:200")
        let dataTask = sessionUnderTest.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                XCTFail("Error:\(error.localizedDescription)")
                return
            }else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                }else {
                    XCTFail("StatusCode:\(statusCode)")
                }
            }
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCallToiTunesCompletes() {
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
        let promise = expectation(description: "Completion handler invoked")
        var statusCode : Int?
        var responseError : Error?
        
        let dataTask = sessionUnderTest.dataTask(with: url!) { (data, response, error) in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
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
