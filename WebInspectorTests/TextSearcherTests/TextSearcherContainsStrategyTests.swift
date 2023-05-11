//
//  TextSearcherContainsStrategyTests.swift
//  WebInspectorTests
//
//  Created by Robert on 23.06.2022.
//

import XCTest
@testable import WebInspector

class TextSearcherContainsStrategyTests: XCTestCase {

    func test_forAllCases_searchStringEmptyAndTextEmpty_searchResultsEmpty() {
        assertThatForAllCaseOptionsSearching(string: "", in: "", hasResult: [])
    }
    
    func test_forAllCases_searchStringEmpty_searchResultsEmpty() {
        assertThatForAllCaseOptionsSearching(string: "", in: "abs", hasResult: [])
    }
    
    func test_forAllCases_textStringEmpty_searchResultsEmpty() {
        assertThatForAllCaseOptionsSearching(string: "abc", in: "", hasResult: [])
    }
    
    func test_forAllCases_noSearchedStringInText_returnEmptyResult() {
        assertThatForAllCaseOptionsSearching(string: "abc", in: "defadfsg", hasResult: [])
    }
    
    func test_forAllCases_searchStringLongerThenText_returnEmptyResults() {
        assertThatForAllCaseOptionsSearching(string: "abc", in: "a", hasResult: [])
    }
    
    func test_forIgnoringCaseOption_searchTextContainsWithDifferentCaseInText_returnSearchResults() {
        let sut = TextSearcherContainsStrategy()
        let text = "abc someABC ab text abc"
        let ranges = sut.search(string: "aBC", in: text, caseOption: .caseInsensitive)
        let expected = [
            range(in: text, location: 0, length: 3),
            range(in: text, location: 8, length: 3),
            range(in: text, location: 20, length: 3),
        ]
        
        XCTAssertEqual(ranges, expected)
    }
    
    func test_forCaseSensitiveOption_searchTex_findOnlyPartsWithMatchedCase() {
        let sut = TextSearcherContainsStrategy()
        let text = "aBC someaBC ab text abc"
        
        let ranges = sut.search(string: "aBC", in: text, caseOption: .caseSensitive)
        let expected = [
            range(in: text, location: 0, length: 3),
            range(in: text, location: 8, length: 3),
        ]
        
        XCTAssertEqual(ranges, expected)
    }
    
    func assertThatForAllCaseOptionsSearching(string: String, in text: String, hasResult: [Range<String.Index>]) {
        let sut = TextSearcherContainsStrategy()
        
        for option in SearchCaseSensitivityOptions.allCases {
            XCTAssertEqual(sut.search(string: string, in: text, caseOption: option), hasResult)
        }
    }

}
