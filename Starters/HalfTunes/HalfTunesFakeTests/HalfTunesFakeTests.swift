//
//  HalfTunesFakeTests.swift
//  HalfTunesFakeTests
//
//  Created by ari 李 on 03/12/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import XCTest
@testable import HalfTunes
class HalfTunesFakeTests: XCTestCase {
//    System Under Test (SUT)
    var controllerUnderTest : SearchViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? SearchViewController
        
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "abbaData", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!),options:.alwaysMapped)
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
        let urlResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sessionMock = URLSessionMock(data: data, response: urlResponse, error: nil)
        controllerUnderTest.defaultSession = sessionMock
    }
    
    func testUpdateSearchResults_ParseData() {
        let promise = expectation(description: "Status code:200")
        XCTAssertEqual(controllerUnderTest.searchResults.count, 0 ,"searchResults should be empty before the data task runs")
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
        
        let dataTask = controllerUnderTest.defaultSession.dataTask(with: url!) {(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    promise.fulfill()
                    self.controllerUnderTest.parseData(data)
                }
            }
        }
        
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(controllerUnderTest?.searchResults.count, 3, "Didn't parse 3 items from fake response")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controllerUnderTest = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test_StartDownload_Performance() {
        // This is an example of a performance test case.
        let track = Track(name: "Waterloo", artist: "ABBA",
                          previewUrl: "http://a821.phobos.apple.com/us/r30/Music/d7/ba/ce/mzm.vsyjlsff.aac.p.m4a")
        measure {
            controllerUnderTest.startDownload(track)
        }
    }
    
}
