//
//  WebActionsLoggerTests.swift
//  WebInspectorTests
//
//  Created by Robert on 04.07.2022.
//

import XCTest
@testable import WebInspector

class WebActionsLoggerTests: XCTestCase {

    var sut: DefaultWebActionsLogger!
    
    override func setUp() {
        super.setUp()
        
        sut = DefaultWebActionsLogger()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func test_logUserAction() {
        sut.log(.userAction("reload"))
        
        XCTAssertEqual(sut.logs, [LoggerAction.userAction("reload")])
    }
    
    func tes_logRequest() {
        let urlRequest = makeUrlRequest()
        
        sut.log(.request(urlRequest))
        
        XCTAssertEqual(sut.logs, [LoggerAction.request(urlRequest)])
    }
    
    func test_logResponse() {
        let urlResponse = makeUrlResponse()
        
        sut.log(.response(urlResponse))
        
        XCTAssertEqual(sut.logs, [LoggerAction.response(urlResponse)])
    }
    
    func test_logRedirect() {
        let url = makeUrl()
        
        sut.log(.redirect(url))
        
        XCTAssertEqual(sut.logs, [LoggerAction.redirect(url)])
    }

}

extension WebActionsLoggerTests {
    func makeUrl() -> URL {
        URL(string: "https://example.com")!
    }
    
    func makeUrlRequest() -> URLRequest {
        URLRequest(url: makeUrl())
    }
    
    func makeUrlResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: makeUrl(), statusCode: 200, httpVersion: "1", headerFields: ["A" : "B"])!
    }
}


