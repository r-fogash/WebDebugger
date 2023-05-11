//
//  DefaultUrlStringRefiner.swift
//  WebInspectorTests
//
//  Created by Robert on 26.05.2022.
//

import XCTest
@testable import WebInspector

class DefaultUrlStringRefiner: XCTestCase {
    
    func test_withNil_returnNil() {
        XCTAssertNil(makeSUT().execute(nil))
    }
    
    func test_withEmptyString_returnNil() {
        XCTAssertNil(makeSUT().execute(""))
    }
    
    func test_withValidUrl_returnUrl() {
        let urlString = "https://google.com"
        let expectedURL = URL(string: urlString)!
        
        let sut = makeSUT()
        let resultUrl = sut.execute(urlString)
        
        XCTAssertEqual(resultUrl, expectedURL)
    }
    
    func test_withUrlWithoutScheme_addScheme() {
        let urlString = "goog.com"
        let sut = makeSUT()
        
        let resultUrl = sut.execute(urlString)
        
        let defaultScheme = "http"
        let expectedUrl = URL(string: defaultScheme + "://" + urlString)!
        
        XCTAssertEqual(resultUrl, expectedUrl)
    }

}

extension DefaultUrlStringRefiner {
    
    func makeSUT() -> DefaultURLStringRefiner {
        DefaultURLStringRefiner()
    }
    
}
