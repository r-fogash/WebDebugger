//
//  CookiesViewModelTests.swift
//  WebInspectorTests
//
//  Created by Robert on 01.07.2022.
//

import XCTest
import Combine
@testable import WebInspector

class CookiesViewModelTests: CookieListViewModelTest_base {

    // MARK: switch between modes
    
    func test_onViewDidLoad_inCookieListMode() {
        let sut = makeSUT()
        sut.onViewDidLoad()
        
        XCTAssertEqual(sut.mode, .cookieList)
    }
    
    func test_whenBeginSearch_inSearchMode() {
        let sut = makeSUTInSearchMode()
        
        XCTAssertEqual(sut.mode, .searchMode)
    }
    
    func test_onFinishSearch_inCookieListMode() {
        let sut = makeSUTInSearchMode()
        sut.onEndSearch()
        
        XCTAssertEqual(sut.mode, .cookieList)
    }
    
    // MARK: dataSnapshot
    
    func test_onCreate_emptyDataSource() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.dataSnapshot.items.isEmpty)
    }
    
    // MARK: Search options view model cooperate
    
    func test_inSearchModeSearchResultNotEmpty_caseOptionDidChange_performSearchWithNewOptions() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        sut.searchOptionsViewModel.caseOption = .caseSensitive
        
        let expectedSearchActions = [
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .contain),
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseSensitive, wrappingOptions: .contain)
        ]
        
        XCTAssertEqual(cookiesSearcherStub.actions, expectedSearchActions)
    }
    
    func test_inSearchModeSearchResultNotEmpty_wrapOptionDidChange_performSearchWithNewOptions() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        sut.searchOptionsViewModel.wrapOption = .matchWord
        
        let expectedSearchActions = [
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .contain),
            CookiesSearcherStub.Action.action(cookies: cookiesFetcherStub.stubbedCookies, field: nil, text: "123", caseOptions: .caseInsensitive, wrappingOptions: .matchWord)
        ]
        
        XCTAssertEqual(cookiesSearcherStub.actions, expectedSearchActions)
    }
    
    func test_onSearchFinish_setNumberOfMatches() {
        calculatorStub.stubbedNumberOfMatches = 2
        let _ = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        XCTAssertEqual(searchOptionsViewModelStub.actions, [.setNumberOfMatches(number: 2)])
    }
    
    func test_inSearchMode_searchOptionsViewModelCurrentItemIndexChange_callSearchResultCalculator() throws {
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
        calculatorStub.stubbedCalculatedItem = .init(item: cookie1, key: "field", range: cookie1Ranges[0])
        searchOptionsViewModelStub.currentFoundItemIndex = 0
        
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        let (currentCookie, currentField, currentRange) = try XCTUnwrap(sut.nextFoundItem)
        
        XCTAssertEqual(currentCookie, cookie1)
        XCTAssertEqual(currentField, "field")
        XCTAssertEqual(currentRange, cookie1Ranges[0])
    }
    
    func test_onCurrentFoundItemChangeToMinusOne_currentFoundItemNil() {
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
        calculatorStub.stubbedCalculatedItem = .init(item: cookie1, key: "field", range: cookie1Ranges[0])
        searchOptionsViewModelStub.currentFoundItemIndex = -1
        
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        
        XCTAssertNil(sut.nextFoundItem)
    }
    
    func test_onBeginSearch_SearchOptionsViewModelSetSearchVisible() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        
        let waiter = PublisherWaiter<Bool>(test: self)
        waiter.wait(on: sut.searchOptionsViewModel.$isSearchToolbarVisible.eraseToAnyPublisher(), expectedValue: true) {
            sut.onBeginSearch()
        }
    }
    
    func test_onEndSearch_SearchOptionViewModelSetSearchVisibleFalse() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        sut.onBeginSearch()
        
        let waiter = PublisherWaiter<Bool>(test: self)
        waiter.wait(on: sut.searchOptionsViewModel.$isSearchToolbarVisible.eraseToAnyPublisher(), expectedValue: false) {
            sut.onEndSearch()
        }
    }
    
    func test_onStartSecondSearch_showAllCookies() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        sut.onEndSearch()
        sut.onBeginSearch()
        
        XCTAssertTrue(!sut.dataSnapshot.items.isEmpty)
    }
    
    func test_onStartSecondSearch_caseOptionChanged_shouldNotReact() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        sut.onEndSearch()
        
        cookiesSearcherStub.actions.removeAll()
        
        sut.onBeginSearch()
        searchOptionsViewModelStub.caseOption = .caseInsensitive
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
    func test_onStartSecondSearch_wrappingOptionsChanged_shouldNotReact() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: nil)
        sut.onEndSearch()
        
        cookiesSearcherStub.actions.removeAll()
        
        sut.onBeginSearch()
        searchOptionsViewModelStub.wrapOption = .contain
        
        XCTAssertEqual(cookiesSearcherStub.actions, [])
    }
    
}

class PublisherWaiter<T> where T: Equatable {
    var bag = Set<AnyCancellable>()
    let test: XCTestCase
    
    init(test: XCTestCase) {
        self.test = test
    }
    
    func wait(on publisher: AnyPublisher<T, Never>, expectedValue: T, action: () -> Void) {
        let expectation = test.expectation(description: "waiting for publishing value")
        
        publisher
            .dropFirst()
            .sink { error in
                XCTFail("expected value \(expectedValue), got error: \(error)")
            } receiveValue: { value in
                if value == expectedValue {
                    expectation.fulfill()
                } else {
                    XCTFail("expected \(expectedValue), got \(value)")
                }
            }
            .store(in: &bag)
        
        action()
        
        test.wait(for: [expectation], timeout: 1)
    }
}
