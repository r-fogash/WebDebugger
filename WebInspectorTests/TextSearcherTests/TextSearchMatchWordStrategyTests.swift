//
//  TextSearchMatchWordStrategyTests.swift
//  WebInspectorTests
//
//  Created by Robert on 23.06.2022.
//

import XCTest
@testable import WebInspector

class TextSearchMatchWordStrategyTests: XCTestCase {

    func test_forAllCaseOptions_searchEmptyStringInEmptyText_returnEmptyResults() {
        assertThatForAllPossibleCaseOptionsSearch(string: "", in: "", returns: [])
    }
    
    func test_forAllCaseOptions_searchEmptyString_returnsEmptyResults() {
        assertThatForAllPossibleCaseOptionsSearch(string: "", in: "hello world!", returns: [])
    }
    
    func test_forAllCaseOptions_searchInEmptyText_returnsEmptyResult() {
        assertThatForAllPossibleCaseOptionsSearch(string: "hello", in: "", returns: [])
    }
    
    func test_forAllCaseOptions_searchStringLongerThatText_returnsEmptyResult() {
        assertThatForAllPossibleCaseOptionsSearch(string: "hello", in: "he", returns: [])
    }
    
    func test_forAllCases_searchedStringInTextButNotWord_returnsEmptyResult() {
        assertThatForAllPossibleCaseOptionsSearch(string: "hello", in: "helloWorld", returns: [])
    }
    
    func test_forCaseSensitiveOption_foundWords_returnResults() {
        let sut = TextSearchMatchWordStrategy()
        let text = "aB ab helloaB aB"
        
        let result = sut.search(string: "aB", in: "aB ab helloaB aB", caseOption: .caseSensitive)
        let expected = [
            range(in: text, location: 0, length: 2),
            range(in: text, location: 14, length: 2)
        ]
        XCTAssertEqual(result, expected)
    }
    
    func test_forIgnoreCaseOption_foundWords_returnResults() {
        let sut = TextSearchMatchWordStrategy()
        let text = "aB ab helloaB aB"
        let result = sut.search(string: "aB", in:text , caseOption: .caseInsensitive)
        let expected = [
            range(in: text, location: 0, length: 2),
            range(in: text, location: 3, length: 2),
            range(in: text, location: 14, length: 2)
        ]
        XCTAssertEqual(result, expected)
    }
    
    func test_forCaseSensitiveOption_searchTwoWordsWhichArePresentIntext_returnresults() {
        let sut = TextSearchMatchWordStrategy()
        let text = "aB A ab A helloaB A aB A { /"
        let result = sut.search(string: "aB A", in: text, caseOption: .caseSensitive)
        let expected = [
            range(in:text , location: 0, length: 4),
            range(in:text , location: 20, length: 4)
        ]
        XCTAssertEqual(result, expected)
    }
    
    func test_forCaseSensitiveOption_searchWordWithNonAlphanumericCharacterWhichArePresentInText_returnresults() {
        let sut = TextSearchMatchWordStrategy()
        let text = "aB } ab } helloaB A aB } { /"
        let result = sut.search(string: "aB }", in: text, caseOption: .caseSensitive)
        let expected = [
            range(in: text, location: 0, length: 4),
            range(in: text, location: 20, length: 4)
        ]
        XCTAssertEqual(result, expected)
    }
    
    /*
    func test_crazy() {
        // é
        let eAcute: Character = "\u{E9}"
        let combinedEAcute: Character = "\u{65}\u{301}"
        
        let text1 = "Hello " + String(eAcute)
        let text2 = "Hello " + String(combinedEAcute)
        
        let nsText1 = text1 as NSString
        let nsText2 = text2 as NSString
        
        XCTAssertEqual(text1, text2)
        XCTAssertEqual(text1 as NSString, text2 as NSString)
        
        let range1 = text1.range(of: "é")
        let range2 = text2.range(of: "é")
        
        let location1 = text1.distance(from: text1.startIndex, to: range1!.lowerBound)
        let len1 = text1.distance(from: text1.startIndex, to: range1!.upperBound) - location1
        
        let location2 = text2.distance(from: text2.startIndex, to: range2!.lowerBound)
        let len2 = text2.distance(from: text2.startIndex, to: range2!.upperBound) - location2
        
        XCTAssertEqual(location1, location2)
        XCTAssertEqual(len1, len2)
        
        print("done")
    }
     */
    
    func assertThatForAllPossibleCaseOptionsSearch(string: String, in text: String, returns: [Range<String.Index>]) {
        let sut = TextSearchMatchWordStrategy()
        
        for option in SearchCaseSensitivityOptions.allCases {
            XCTAssertEqual(sut.search(string: string, in: text, caseOption: option), returns)
        }
    }

}
