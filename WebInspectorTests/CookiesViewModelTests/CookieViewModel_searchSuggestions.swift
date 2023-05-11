//
//  CookieViewModel_searching.swift
//  WebInspectorTests
//
//  Created by Robert on 03.07.2022.
//

import XCTest
@testable import WebInspector

class CookieViewModel_searching: CookieListViewModelTest_base {

    func test_onStartSearch_datasourceHoldsSameItemsAsBeforeSearch() {
        let sut = makeSUT()
        let cookie1 = makeSimpleCookie(namePropertyValue: "c_name_1", valuePropertyValue: "c_value_1")
        let cookie2 = makeSimpleCookie(namePropertyValue: "c_name_2", valuePropertyValue: "c_value_2")
        cookiesFetcherStub.stubbedCookies = [cookie1, cookie2]
        
        sut.onViewDidLoad()
        sut.onBeginSearch()
        
        XCTAssertEqual(sut.dataSnapshot.items, [.init(cookie: cookie1, isHeader: true),
                                                .init(cookie: cookie1, isHeader: false),
                                                .init(cookie: cookie2, isHeader: true),
                                                .init(cookie: cookie2, isHeader: false)])
    }
    
    func test_onStartSearch_showSuggestionsList() {
        let sut = makeSUTInSearchMode()
        
        XCTAssertTrue(sut.showsSuggestions)
    }
    
    func test_whenInSearchMode_selectToken_hideSuggestions() {
        let sut = makeSUTInSearchMode()
        
        sut.didSelect(suggestion: HTTPCookiePropertyKey.name)
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenInSearchMode_enterText_hideSuggestions() {
        let sut = makeSUTInSearchMode()
        
        sut.didChange(searchText: "a")
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenSearchSuggestionVisible_onCloseSearchMode_hideSuggestions() {
        let sut = makeSUTInSearchMode()
        
        sut.onEndSearch()
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenSearchSuggestionsVisible_onEnterText_hideSearchSuggestions(){
        let sut = makeSUTInSearchModeWith(searchText: "a", selectedSearchToken: nil)
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenSearchSuggestionsVisible_onSelectToken_hideSearchSuggestions() {
        let sut = makeSUTInSearchModeWith(searchText: nil, selectedSearchToken: HTTPCookiePropertyKey.name)
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenSearchSuggestionsHiddenAndSearchTextAndSearchTokenSet_onClearSearchToken_searchSuggestionsHidden() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: HTTPCookiePropertyKey.name)
        
        sut.onSearchCriteriaDidChange(text: "123", token: nil)
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_whenSearchSuggestionsHiddenAndSearchTextAndSearchTokenSet_onClearSearchText_searchSuggestionsHidden() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: HTTPCookiePropertyKey.name)
        
        sut.onSearchCriteriaDidChange(text: nil, token: HTTPCookiePropertyKey.name)
        
        XCTAssertFalse(sut.showsSuggestions)
    }
    
    func test_onSearchSuggestionsHiddenAndSearchTextAndSearchTokenSet_onClearSearchTextAndToken_searchSuggestionsVisible() {
        let sut = makeSUTInSearchModeWith(searchText: "123", selectedSearchToken: HTTPCookiePropertyKey.name)
        
        sut.onSearchCriteriaDidChange(text: nil, token: nil)
        
        XCTAssertTrue(sut.showsSuggestions)
    }
    
    func test_inCookieListMode_clearSearchTextAndToken_searchSuggestionsNotVisible() {
        let sut = makeSUTInSearchMode()
        sut.onEndSearch()
        sut.onSearchCriteriaDidChange(text:nil, token:nil)
        
        XCTAssertFalse(sut.showsSuggestions)
    }

}
