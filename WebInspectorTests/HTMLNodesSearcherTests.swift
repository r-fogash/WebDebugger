//
//  HTMLNodesSearcherTests.swift
//  WebInspectorTests
//
//  Created by Robert on 23.06.2022.
//

import XCTest
@testable import WebInspector

class HTMLNodesSearcherTests: XCTestCase {
    
    var textSearcher: TextSearcherSpy!
    let searchText = "STUB SEARCH TEXT"
    
    override func setUp() {
        super.setUp()
        
        textSearcher = TextSearcherSpy()
    }
    
    override func tearDown() {
        textSearcher = nil
        
        super.tearDown()
    }
    
    func test_execute_willCallSearchForAnyCaseAndWrappingOptions() {
        let sut = makeSUT()
        let node = HTMLNode(text: searchText, child: [], attributes: [:])
        
        for caseOption in SearchCaseSensitivityOptions.allCases {
            for wrappingOption in SearchWordWrappingOptions.allCases {
                let _ = sut.execute(text: searchText, in: node, caseOption: caseOption, wrappingOptions: wrappingOption)
            }
        }
        
        XCTAssertEqual(textSearcher.actions.count, SearchCaseSensitivityOptions.allCases.count * SearchWordWrappingOptions.allCases.count)
    }
    
    func test_execute_searchInAllHTMLNodes() {
        let node = makeHTMLNode()
        let sut = makeSUT()
        
        let _ = sut.execute(text: searchText, in: node, caseOption: .caseInsensitive, wrappingOptions: .contain)
        
        XCTAssertEqual(textSearcher.actions.count, numberOfAllNodes(in: node))
    }
    
    func test_execute_noSearchMatch_returnEmptySearchResult() {
        let node = makeHTMLNode()
        let sut = makeSUT()
        
        let result = sut.execute(text: searchText, in: node, caseOption: .caseInsensitive, wrappingOptions: .contain)
        
        XCTAssertTrue(result.items.isEmpty)
    }
    
    func test_matchFoundInNode_returnThatNodeAndMatchRanges() {
        let sut = makeSUT()
        let node = makeHTMLNode()
        
        // select a node which should contain search text
        let nodeWithMath = node.child[0]
        
        // prepare ranges
        let text = nodeWithMath.text
        let range1 = text.startIndex ..< text.index(text.startIndex, offsetBy: 1)
        let range2 = text.index(text.startIndex, offsetBy: 3) ..< text.index(text.startIndex, offsetBy: 4)
        let foundRanges = [ range1, range2 ]
        
        // set mocks
        let mockedResult = TextSearcherStub.ResultHandler(result: foundRanges, text: nodeWithMath.text)
        textSearcher.resultHandlers.append(mockedResult)
        
        let result = sut.execute(text: searchText, in: node, caseOption: .caseInsensitive, wrappingOptions: .matchWord)
        
        let expectedResult = SearchResults(items: [ .init(item: nodeWithMath, ranges: foundRanges) ])
        
        XCTAssertEqual(result.items, expectedResult.items)
    }
    
    func test_numberOfAllNodesMethod() {
        XCTAssertEqual(numberOfAllNodes(in: makeHTMLNode()), 3)
        XCTAssertEqual(numberOfAllNodes(in: HTMLNode(text: "DUMMY", child: [], attributes: [:])), 1)
    }

}

extension HTMLNodesSearcherTests {
    
    func makeHTMLNode() -> HTMLNode {
        HTMLNode(
            text: "<Html></Html>",
            child: [
                HTMLNode(text: "<head a=\"b\"></head>", child: [], attributes: ["a":"b"]),
                HTMLNode(text: "<body attr1=\"value 1\" attr2=\"value 2\"></body>", child: [], attributes: ["attr1":"value1", "attr2":"value2"]),
            ],
            attributes: [:])
    }
    
    func numberOfAllNodes(in node: HTMLNode) -> Int {
        node.child.reduce(0) { partialResult, node in
            partialResult + numberOfAllNodes(in: node)
        } + 1
    }
    
    func makeSUT() -> HTMLNodesSearcher {
        HTMLNodesSearcher(textSearcher: textSearcher)
    }
    
}


