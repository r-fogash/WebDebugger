//
//  SearchOptionsViewModelTests.swift
//  WebInspectorTests
//
//  Created by Robert on 25.06.2022.
//

import XCTest
@testable import WebInspector

class SearchOptionsViewModelTests: XCTestCase {

    func test_initialState() {
        assertIsSearchOptionsViewModeInitialState(makeSUT())
    }
    
    func test_onSearchToolbarVisibleToggle_resetCaseOptions() {
        let sut = makeSUT()
        sut.isSearchToolbarVisible = true
        
        sut.caseOption = .caseSensitive
        sut.isSearchToolbarVisible = false
        
        XCTAssertEqual(sut.caseOption, .caseInsensitive)
    }
    
    func test_onSearchToolbarVisibilityToggle_resetWrapOption() {
        let sut = makeSUT()
        sut.isSearchToolbarVisible = true
        
        sut.wrapOption = .matchWord
        sut.isSearchToolbarVisible = false
        
        XCTAssertEqual(sut.wrapOption, .contain)
    }
    
    //TODO: do not change case sensitivity on search visible
    func test_onSearchToolbarVisibilityToggle_doNotChangeCaseOptions() {
        let sut = makeSUT()
        sut.isSearchToolbarVisible = true
        sut.caseOption = .caseSensitive
        sut.isSearchToolbarVisible = false

        XCTAssertEqual(sut.caseOption, .caseInsensitive)
        
        sut.caseOption = .caseSensitive
        sut.isSearchToolbarVisible = true
        
        XCTAssertEqual(sut.caseOption, .caseSensitive)
    }
    
    func test_onSearchToolbarVisibilityToggle_resetCanGoBack() {
        let sut = makeSUT(numberOfFoundItems: 10)
        
        sut.nextFoundItem()
        sut.isSearchToolbarVisible = false
        sut.isSearchToolbarVisible = true
        
        XCTAssertFalse(sut.canGoBackward)
    }
    
    func test_onSearchToolbarVisibilityToggle_resetCanGoForward() {
        let sut = makeSUT(numberOfFoundItems: 10)
        
        sut.isSearchToolbarVisible = false
        sut.isSearchToolbarVisible = true
        
        XCTAssertFalse(sut.canGoForward)
    }
    
    func test_onSearchToolbarVisibilityToggle_resetSearchResultsDescription() {
        let sut = makeSUT(numberOfFoundItems: 10)
        
        sut.isSearchToolbarVisible = false
        sut.isSearchToolbarVisible = true
        
        XCTAssertEqual(sut.searchResultsDescription, "")
    }
    
    func test_onSearchToolbarVisibilityToggle_resetCurrentFoundItemIndex() {
        let sut = makeSUT(numberOfFoundItems: 10)
        
        sut.isSearchToolbarVisible = false
        sut.isSearchToolbarVisible = true
        
        XCTAssertEqual(sut.currentFoundItemIndex, -1)
    }
    
    // setting search results
    
    func test_onSetNumberOfMatchesNull_canGoBackFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 0)
        
        XCTAssertFalse(sut.canGoBackward)
    }
    
    func test_onSetNumberOfMatchesNull_canGoForwardFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 0)
        
        XCTAssertFalse(sut.canGoForward)
    }
    
    func test_onSetNumberOfMatchesNull_currentFoundItemIndexChangesToDefaultValue() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 0)
        
        XCTAssertEqual(sut.currentFoundItemIndex, -1)
    }
    
    func test_onSetNumberOfMatchesToOne_canGoForwardFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 1)
        
        XCTAssertFalse(sut.canGoForward)
    }
    
    func test_onSetNumberOfMatchesGreaterThanOne_canGoBackwardFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        XCTAssertFalse(sut.canGoBackward)
    }
    
    func test_onSetNumberOfMatchesGreaterThanOne_canGoForwardTrue() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        XCTAssertTrue(sut.canGoForward)
    }
    
    func test_onSetNumberOfMatchesGreaterThanOne_currentFoundItemIsNull() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        XCTAssertEqual(sut.currentFoundItemIndex, 0)
    }
    
    func test_onSetNumberOfMatchesGreaterThanOne_updateResultsDescription() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        XCTAssertEqual(sut.searchResultsDescription, "1/10")
    }
    
    func test_onSetNumberOfMatchesToZero_resultDescriptionIsNoMatch() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 0)
        
        XCTAssertEqual(sut.searchResultsDescription, "No match")
    }
    
    func test_givenNumberOfMatchesGreaterThanOne_onTouchNext_canGaBackwardActive() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        sut.nextFoundItem()
        
        XCTAssertTrue(sut.canGoBackward)
    }
    
    func test_givenNumberOfMatchesGreaterThanFive_touchNextItemFiveTimes_canGoForwardIsFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 5)
        
        for _ in 0..<5 {
            sut.nextFoundItem()
        }
        
        XCTAssertFalse(sut.canGoForward)
    }
    
    func test_sgivenNumberOfMatchesGreaterThanOne_onNextItem_incrementCurrentFoundItem() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        sut.nextFoundItem()
        
        XCTAssertEqual(sut.currentFoundItemIndex, 1)
    }
    
    func test_givenNumberOfMatchesGreaterThanOne_onNextItem_updateSearchDescription() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        sut.nextFoundItem()
        
        XCTAssertEqual(sut.searchResultsDescription, "2/10")
    }
    
    func test_givenNumberOfMatchesSetToTen_touchNextItemThenPreviousItemTwoTimes_canGoBackFalse() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        sut.nextFoundItem()
        sut.nextFoundItem()
        sut.previousFoundItem()
        sut.previousFoundItem()
        
        XCTAssertFalse(sut.canGoBackward)
    }
    
    func test_canGoBack_onPreviousItem_decrementCurrentFoundItem() {
        let sut = makeSUT()
        sut.set(numberOfMatches: 10)
        
        sut.nextFoundItem()
        sut.previousFoundItem()
        
        XCTAssertEqual(sut.currentFoundItemIndex, 0)
    }
    
    func assertIsSearchOptionsViewModeInitialState(_ model: DefaultSearchOptionsViewModel) {
        XCTAssertEqual(model.caseOption, .caseInsensitive)
        XCTAssertEqual(model.wrapOption, .contain)
        XCTAssertFalse(model.isSearchToolbarVisible)
        XCTAssertFalse(model.canGoBackward)
        XCTAssertFalse(model.canGoForward)
        XCTAssertEqual(model.searchResultsDescription, "")
        XCTAssertEqual(model.currentFoundItemIndex, -1)
    }
    
}

extension SearchOptionsViewModelTests {
    
    func makeSUT() -> DefaultSearchOptionsViewModel {
        DefaultSearchOptionsViewModel()
    }
    
    func makeSUT(numberOfFoundItems: Int) -> DefaultSearchOptionsViewModel {
        let sut = makeSUT()
        sut.isSearchToolbarVisible = true
        sut.set(numberOfMatches: numberOfFoundItems)
        return sut
    }
    
}
