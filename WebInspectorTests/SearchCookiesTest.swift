//
//  DefaultCookiesSearcher.swift
//  WebInspectorTests
//
//  Created by Robert on 30.06.2022.
//

import XCTest
@testable import WebInspector

class CookiesSearcherTests: XCTestCase {

    var textSearcher: TextSearcherSpy!
    let searchText = "STUB SEARCH TEXT"
    
    override func setUpWithError() throws {
        textSearcher = TextSearcherSpy()
    }

    override func tearDownWithError() throws {
        textSearcher = nil
    }
    
    func test_executeWithNullCookieAttribute_searchInAllCookieAttributes() {
        let sut = makeSUT()
        let cookie = makeCookie()
        let expectedActions = cookie.attributes
            .map {
                TextSearcherSpy.Action.search(string: searchText,
                                               text: $0.value,
                                               caseOption: .caseInsensitive,
                                               wrappingOption: .contain)
            }
        
        let _ = sut.execute(with: searchText,
                            in: [cookie],
                            cookieAttribute: nil,
                            caseOption: .caseInsensitive,
                            wrappingOptions: .contain)
        
        XCTAssertEqual(textSearcher.actions, expectedActions)
    }
    
    func test_executeWithSpecifiedCookieAttribute_searchOnlyInSpecifiedAttribute() {
        let cookieValueAttributeValue = "ACX-01"
        let cookie = makeCookie(valueFieldValue: cookieValueAttributeValue)
        let sut = makeSUT()

        
        let expectedAction = TextSearcherSpy.Action.search(string: searchText,
                                                            text: cookieValueAttributeValue,
                                                            caseOption: .caseInsensitive,
                                                            wrappingOption: .contain)
        
        let _ = sut.execute(with: searchText,
                            in: [cookie],
                            cookieAttribute: HTTPCookiePropertyKey.value,
                            caseOption: .caseInsensitive,
                            wrappingOptions: .contain)
        
        XCTAssertEqual(textSearcher.actions, [expectedAction])
    }
    
    func test_searchInEmptyCookieList_resultIsEmpty() {
        let sut = makeSUT()
        
        let result: SearchResults<Cookie> = sut.execute(with: searchText,
                                                        in: [],
                                                        cookieAttribute: nil,
                                                        caseOption: .caseInsensitive,
                                                        wrappingOptions: .matchWord)
        
        XCTAssertTrue(result.items.isEmpty)
    }
    
    func test_search_findMultiplyFields_returnCorrectResults() {
        let cookie = makeCookie()
        
        let sut = makeSUT()
        
        let field1 = cookie.attributes[0]
        let field2 = cookie.attributes[1]
        let field1Ranges = [field1.value.startIndex..<field1.value.endIndex]
        let field2Ranges = [field2.value.startIndex..<field2.value.endIndex]
        let resultStub1 = TextSearcherSpy.ResultHandler(result: field1Ranges, text: field1.value)
        let resultStub2 = TextSearcherSpy.ResultHandler(result: field2Ranges, text: field2.value)
        
        textSearcher.resultHandlers = [resultStub1, resultStub2]
        
        let expectedResult = SearchResults<Cookie>.init(items: [
            .init(item: cookie, key: cookie.attributes[0].name.rawValue, ranges: field1Ranges),
            .init(item: cookie, key: cookie.attributes[1].name.rawValue, ranges: field2Ranges)
        ])
        
        let result : SearchResults<Cookie> = sut.execute(with: searchText,
                                                         in: [cookie],
                                                         cookieAttribute: nil,
                                                         caseOption: .caseInsensitive,
                                                         wrappingOptions: .contain)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_aggregateSearchResultsFromMultiplyCookies() {
        let cookie1 = makeCookie(valueFieldValue: "AABC-F1-0", commentFieldValue: "comment for cookie 1")
        let cookie2 = makeCookie(valueFieldValue: "AABC-F1-1", commentFieldValue: "comment for cookie 2")
        let cookie3 = makeCookie(valueFieldValue: "AABC-F1-2", commentFieldValue: "comment for cookie 3")
        
        let cookie1_valueField_foundRanges = ["AABC-F1-0".startIndex..<"AABC-F1-0".endIndex]
        let cookie1_commentField_foundRanges = ["comment for cookie 1".startIndex..<"comment for cookie 1".endIndex]
        let cookie2_valueField_foundRanges = ["AABC-F1-1".startIndex..<"AABC-F1-1".endIndex]
        
        let resultStub01 = TextSearcherSpy.ResultHandler.init(result: cookie1_valueField_foundRanges, text:"AABC-F1-0")
        let resultStub02 = TextSearcherSpy.ResultHandler.init(result: cookie1_commentField_foundRanges, text:"comment for cookie 1")
        let resultStub2 = TextSearcherSpy.ResultHandler.init(result: cookie2_valueField_foundRanges, text:"AABC-F1-1")
        
        textSearcher.resultHandlers = [resultStub01, resultStub02, resultStub2]
        
        let sut = makeSUT()
        let result : SearchResults<Cookie> = sut.execute(with: searchText,
                                                         in: [cookie1, cookie2, cookie3],
                                                         cookieAttribute: nil,
                                                         caseOption: .caseInsensitive,
                                                         wrappingOptions: .contain)
        
        let expectedResult = SearchResults<Cookie>.init(items: [
            .init(item: cookie1, key: HTTPCookiePropertyKey.value.rawValue, ranges: cookie1_valueField_foundRanges),
            .init(item: cookie1, key: HTTPCookiePropertyKey.comment.rawValue, ranges: cookie1_commentField_foundRanges),
            .init(item: cookie2, key: HTTPCookiePropertyKey.value.rawValue, ranges: cookie2_valueField_foundRanges)
        ])
        
        XCTAssertEqual(result, expectedResult)
    }

}

extension CookiesSearcherTests {
    
    func makeSUT() -> DefaultCookiesSearcher {
        DefaultCookiesSearcher(textSearcher: textSearcher)
    }

    func makeCookie() -> Cookie {
        makeCookie(valueFieldValue: "XCA-1FF_3")
    }
    
    func makeCookie(valueFieldValue: String, commentFieldValue: String = "some comment") -> Cookie {
        let fields = [
            CookieAttribute(name: HTTPCookiePropertyKey.version, value: "1"),
            CookieAttribute(name: HTTPCookiePropertyKey.value, value: valueFieldValue),
            CookieAttribute(name: HTTPCookiePropertyKey.expires, value: "2022-03-18"),
            CookieAttribute(name: HTTPCookiePropertyKey.discard, value: "FALSE"),
            CookieAttribute(name: HTTPCookiePropertyKey.domain, value: "domain.com"),
            CookieAttribute(name: HTTPCookiePropertyKey.path, value: "/articles"),
            CookieAttribute(name: HTTPCookiePropertyKey.secure, value: "TRUE"),
            CookieAttribute(name: HTTPCookiePropertyKey.comment, value: commentFieldValue),
            CookieAttribute(name: HTTPCookiePropertyKey.commentURL, value: "https://comments.com/comment_for_this_cookie"),
            CookieAttribute(name: HTTPCookiePropertyKey.port, value: "1,2,3")
        ]
        return Cookie(fields: fields)
    }
    
}
