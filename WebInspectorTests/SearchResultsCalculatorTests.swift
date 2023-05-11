//
//  SearchResultsCalculatorTests.swift
//  WebInspectorTests
//
//  Created by Robert on 02.07.2022.
//

import XCTest
@testable import WebInspector

typealias ItemType = String

class SearchResultsCalculatorTests: XCTestCase {

    // MARK: Calculating search results
    
    func test_givenEmptySearchResults_numberOfMathes_returnZero() {
        let sut = makeSUT()
        let results = makeEmptySearchResult()
        
        XCTAssertEqual(sut.numberOfMatches(in: results), 0)
    }
    
    func test_givenSearchResultsItemWithEmptyRanges_numberOfMatches_zero() {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello"], numberOfRangesInEach: [0])
        
        XCTAssertEqual(sut.numberOfMatches(in: results), 0)
    }
    
    func test_givenSearchResultsItemWithTwoRanges_numberOfMatches_two() {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello"], numberOfRangesInEach: [2])
        
        XCTAssertEqual(sut.numberOfMatches(in: results), 2)
    }
    
    func test_givenTwoSearchResultsItemsWithTwoRangesEach_numberOfMatches_four() {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello", "World"], numberOfRangesInEach: [2, 2])
        
        XCTAssertEqual(sut.numberOfMatches(in: results), 4)
    }
    
    // MARK: Iterating threw search results

    func test_givenEmptyResults_gettingFirstItem_throwException() {
        let sut = makeSUT()
        let results = makeEmptySearchResult()
        
        XCTAssertThrowsError(try sut.item(at: 0, in: results))
    }
    
    func test_giveNotEmptySearchResultsItems_fetchItemOutOfRange_throws() {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello", "World"], numberOfRangesInEach: [2, 2])
        
        XCTAssertThrowsError(try sut.item(at: 4, in: results))
    }
    
    func test_givenSearchResultsItemWithOneRange_gettingFirstResult_returnTheOnlyItem() throws {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello"], numberOfRangesInEach: [1])
        let expectedItem: SearchResultsCalculator<ItemType>.CalculatedItem
            = .init(item: results.items[0].item, key: "", range: results.items[0].ranges[0])
        
        let item = try sut.item(at: 0, in: results)
        XCTAssertEqual(item, expectedItem)
    }
    
    func test_givenSearchResultsItemWithTwoRanges_gettingSecondResult_returnSecondRange() throws {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello"], numberOfRangesInEach: [2])
        let expectedItem = results.items[0]
        let expectedResult: SearchResultsCalculator<ItemType>.CalculatedItem
            = .init(item: expectedItem.item, key: "", range: expectedItem.ranges[1])
        
        let result = try sut.item(at: 1, in: results)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_givenTwoSearchResultsItemsWithTwoRangesEach_gettingThirdResult_returnSecondItemsFirstRange() throws {
        let sut = makeSUT()
        let results = makeSearchResultsWith(text: ["Hello", "World"], numberOfRangesInEach: [2, 2])
        let expectedItem = results.items[1]
        let expectedResult: SearchResultsCalculator<ItemType>.CalculatedItem
        = .init(item: expectedItem.item, key: "", range: expectedItem.ranges[0])
        
        let result = try sut.item(at: 2, in: results)
        
        XCTAssertEqual(result, expectedResult)
    }
}

extension SearchResultsCalculatorTests {
    
    func makeSUT() ->SearchResultsCalculator<ItemType> {
        .init()
    }
    
    func makeEmptySearchResult() -> SearchResults<ItemType> {
        .init(items: [])
    }
    
    func makeSearchResultWithOneItemAndEmptyRanges() -> SearchResults<ItemType> {
        let item = SearchResults<ItemType>.Item(item: "A", ranges: [])
        return .init(items: [item])
    }
    
    func makeSearchResultsWith(text: [String], numberOfRangesInEach: [Int]) -> SearchResults<ItemType> {
        let items = zip(text, numberOfRangesInEach).map { (text, numberOfRanges) in
            makeSearchResultItem(text: text, numberOfRanges: numberOfRanges)
        }
        return .init(items: items)
    }
 
    func makeSearchResultItem(text: String, numberOfRanges: Int) -> SearchResults<ItemType>.Item {
        var ranges = [Range<String.Index>]()
        
        for i in 0..<numberOfRanges {
            let start = text.index(text.startIndex, offsetBy: i)
            let end = text.endIndex
            ranges.append(start..<end)
        }
        
        return .init(item: text, ranges: ranges)
    }
    
}
