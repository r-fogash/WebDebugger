//
//  CookiesViewModelTests_searching.swift
//  WebInspectorTests
//
//  Created by Robert on 03.07.2022.
//

import XCTest
@testable import WebInspector

class CookiesViewModelTests_searching: CookieListViewModelTest_base {

    func test_inSearchModeEnterText_searchByText() {
        let _ = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        let expectedSearchActions = [
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .contain)
        ]
        
        XCTAssertEqual(cookiesSearcherStub.actions, expectedSearchActions)
    }
    
    func test_inSearchModeEnterEmptyTest_searchNotPerformed() {
        let _ = makeSUTInSearchModeWith(searchText: "", selectedSearchToken: nil)
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
    func test_inSearchMode_enterInlyToken_searchNotPerformed() {
        let _ = makeSUTInSearchModeWith(searchText: nil, selectedSearchToken: HTTPCookiePropertyKey.name)
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
    func test_inSearchMode_clearSearchCriteria_searchNotPerformed() {
        let _ = makeSUTInSearchModeWith(searchText: nil, selectedSearchToken: nil)
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
    func test_notInSearchMode_enterSearchCriteria_searchNotPerformed() {
        let sut = makeSUTInSearchMode()
        sut.onEndSearch()
        sut.onSearchCriteriaDidChange(text: "123", token: nil)
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
    func test_inSearchMode_enterTextAndToken_performSearchWithTextAndToken() {
        let _ = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: HTTPCookiePropertyKey.name)
        
        let expectedSearchActions = [
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: HTTPCookiePropertyKey.name, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .contain)
        ]
        
        XCTAssertEqual(cookiesSearcherStub.actions, expectedSearchActions)
    }
    
    func test_didFindSearchResults_searchResultsInDatasourceAllExpanded() {
        let cookie1 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.path, value: "/book"),
            .init(name: HTTPCookiePropertyKey.name, value: "cookie 1 res")
        ])
        let cookie2 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.comment, value: "a comment"),
            .init(name: HTTPCookiePropertyKey.domain, value: "example.com")
        ])
        let cookie1SearchResults = ["field" : [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]]
        let cookie2SearchResults = ["field" : [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex]]
        
        let stubbedResults = SearchResults<Cookie>(items: [
            .init(item: cookie1, key: "field", ranges: [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]),
            .init(item: cookie2, key: "field", ranges: [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex])
        ])
        
        cookiesSearcherStub.stubbedSearchResult = stubbedResults
        
        let expectedCookies = [
            CookieItemModel(cookie: cookie1, isHeader: true, searchResults: [:]),
            CookieItemModel(cookie: cookie1, isHeader: false, searchResults: cookie1SearchResults),
            CookieItemModel(cookie: cookie2, isHeader: true, searchResults: [:]),
            CookieItemModel(cookie: cookie2, isHeader: false, searchResults: cookie2SearchResults)
        ]
        
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        XCTAssertEqual(sut.dataSnapshot.items, expectedCookies)
    }
    
    func test_subsequentSearchesHappensFromMainCookieList() {
        let sut = makeSUTInSearchMode()
        
        let cookie1 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.path, value: "/book"),
            .init(name: HTTPCookiePropertyKey.name, value: "cookie 1 res")
        ])
        let cookie2 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.comment, value: "a comment"),
            .init(name: HTTPCookiePropertyKey.domain, value: "example.com")
        ])
        let cookie1Ranges = [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]
        let cookie2Ranges = [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex]
        
        let stubbedResults = SearchResults<Cookie>(items: [
            .init(item: cookie1, key: "field", ranges: cookie1Ranges),
            .init(item: cookie2, key: "field", ranges: cookie2Ranges),
        ])
        
        cookiesSearcherStub.stubbedSearchResult = stubbedResults
        
        sut.onSearchCriteriaDidChange(text: "123", token: nil)
        sut.onSearchCriteriaDidChange(text: "1234", token: nil)
        
        let expectedSearchActions = [
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .contain),
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "1234", caseOptions: .caseInsensitive, wrappingOptions: .contain)
        ]
        
        XCTAssertEqual(cookiesSearcherStub.actions, expectedSearchActions)
    }
    
    func test_onFinishSearch_restoreOriginalCookiesList() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        
        let cookiesBeforeSearch = sut.dataSnapshot.items
        
        let cookie1 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.path, value: "/book"),
            .init(name: HTTPCookiePropertyKey.name, value: "cookie 1 res")
        ])
        let cookie2 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.comment, value: "a comment"),
            .init(name: HTTPCookiePropertyKey.domain, value: "example.com")
        ])
        
        let cookie1Ranges = [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]
        let cookie2Ranges = [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex]
        
        let stubbedResults = SearchResults<Cookie>(items: [
            .init(item: cookie1, key: "field", ranges: cookie1Ranges),
            .init(item: cookie2, key: "field", ranges: cookie2Ranges),
        ])
        
        cookiesSearcherStub.stubbedSearchResult = stubbedResults
        
        sut.onBeginSearch()
        sut.onSearchCriteriaDidChange(text: "123", token: nil)
        sut.onEndSearch()
        
        XCTAssertEqual(sut.dataSnapshot.items, cookiesBeforeSearch)
    }
    
    func test_searchResultsAreExpanded() {
        let cookie1 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.path, value: "/book"),
            .init(name: HTTPCookiePropertyKey.name, value: "cookie 1 res")
        ])
        let cookie2 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.comment, value: "a comment"),
            .init(name: HTTPCookiePropertyKey.domain, value: "example.com")
        ])
        
        let cookie1Ranges = [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]
        let cookie2Ranges = [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex]
        
        let stubbedResults = SearchResults<Cookie>(items: [
            .init(item: cookie1, key: "field", ranges: cookie1Ranges),
            .init(item: cookie2, key: "field", ranges: cookie2Ranges),
        ])
        
        cookiesSearcherStub.stubbedSearchResult = stubbedResults
        
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)

        let rootItems = sut.dataSnapshot.items.filter { sut.dataSnapshot.level(of: $0) == 0 }
        
        XCTAssertTrue( rootItems.allSatisfy{sut.dataSnapshot.isExpanded($0)} )
    }
    
    func test_inSearchModeEnterEmptyTest_showAllItems() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        let itemsBeforeSearch = sut.dataSnapshot.items
        
        let cookie1 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.path, value: "/book"),
            .init(name: HTTPCookiePropertyKey.name, value: "cookie 1 res")
        ])
        let cookie2 = Cookie(fields: [
            .init(name: HTTPCookiePropertyKey.comment, value: "a comment"),
            .init(name: HTTPCookiePropertyKey.domain, value: "example.com")
        ])
        
        let cookie1Ranges = [cookie1.attributes.first!.value.startIndex..<cookie1.attributes.first!.value.endIndex]
        let cookie2Ranges = [cookie2.attributes.first!.value.startIndex..<cookie2.attributes.first!.value.endIndex]
        
        let stubbedResults = SearchResults<Cookie>(items: [
            .init(item: cookie1, key: "field", ranges: cookie1Ranges),
            .init(item: cookie2, key: "field", ranges: cookie2Ranges),
        ])
        
        cookiesSearcherStub.stubbedSearchResult = stubbedResults
        
        sut.onBeginSearch()
        sut.onSearchCriteriaDidChange(text: "123", token: nil)
        sut.onSearchCriteriaDidChange(text: "", token: nil)
        
        XCTAssertEqual(sut.dataSnapshot.items, itemsBeforeSearch)
    }
}
