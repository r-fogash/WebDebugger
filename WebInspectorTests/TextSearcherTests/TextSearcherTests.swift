//
//  TextSearcherTests.swift
//  WebInspectorTests
//
//  Created by Robert on 23.06.2022.
//

import XCTest
@testable import WebInspector

class TextSearcherTests: XCTestCase {
    
    fileprivate var containsStrategy: WordContainsStrategyStub!
    fileprivate var wordMatchStrategy: WordMathStrategyStub!
    
    override func setUp() {
        super.setUp()
        
        containsStrategy = WordContainsStrategyStub()
        wordMatchStrategy = WordMathStrategyStub()
    }
    
    override func tearDown() {
        containsStrategy = nil
        wordMatchStrategy = nil
        
        super.tearDown()
    }
    
    func test_forAnyCaseOption_searchWithWordMatchOption_callsWordMatchStrategy() {
        let sut = makeSUT()
        let allPossibleCaseOptions = SearchCaseSensitivityOptions.allCases
        
        for caseOption in allPossibleCaseOptions {
            let _ = sut.execute(string: "abc", in: "abc", caseOption: caseOption, wrappingOptions: .matchWord)
        }
        
        XCTAssertEqual(wordMatchStrategy.numberOfCalls, allPossibleCaseOptions.count)
        XCTAssertEqual(containsStrategy.numberOfCalls, 0)
    }
    
    func test_searchWithContainsOption_callsContainsStrategy() {
        let sut = makeSUT()
        let allPossibleCaseOptions = SearchCaseSensitivityOptions.allCases
        
        for caseOption in allPossibleCaseOptions {
            let _ = sut.execute(string: "abc", in: "abc", caseOption: caseOption, wrappingOptions: .contain)
        }
        
        XCTAssertEqual(containsStrategy.numberOfCalls, allPossibleCaseOptions.count)
        XCTAssertEqual(wordMatchStrategy.numberOfCalls, 0)
    }

}

extension TextSearcherTests {
    func makeSUT() -> DefaultTextSearcher {
        DefaultTextSearcher(wordContainsStrategy: containsStrategy, wordMatchStrategy: wordMatchStrategy)
    }
}

private class WordContainsStrategyStub: TextSearcherWrappingStrategy {
    var numberOfCalls = 0
    
    func search(string: String, in text: String, caseOption: SearchCaseSensitivityOptions) -> [Range<String.Index>] {
        numberOfCalls += 1
        return []
    }
}

private class WordMathStrategyStub: TextSearcherWrappingStrategy {
    var numberOfCalls = 0
    
    func search(string: String, in text: String, caseOption: SearchCaseSensitivityOptions) -> [Range<String.Index>] {
        numberOfCalls += 1
        return []
    }
}
