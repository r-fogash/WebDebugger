//
//  CookieListViewModelTest_base.swift
//  WebInspectorTests
//
//  Created by Robert on 03.07.2022.
//

import XCTest
@testable import WebInspector

class CookieListViewModelTest_base: XCTestCase {

    var cookiesFetcherStub: CookiesFetcherStub!
    var cookiesSearcherStub: CookiesSearcherStub!
    var searchOptionsViewModelStub: SearchOptionsViewModelStub!
    var calculatorStub: CalculatorStub!
    
    override func setUpWithError() throws {
        cookiesFetcherStub = CookiesFetcherStub()
        cookiesSearcherStub = CookiesSearcherStub()
        searchOptionsViewModelStub = SearchOptionsViewModelStub()
        calculatorStub = CalculatorStub()
    }

    override func tearDownWithError() throws {
        cookiesFetcherStub = nil
        cookiesSearcherStub = nil
        searchOptionsViewModelStub = nil
        calculatorStub = nil
    }
    
    public func makeSUT() -> CookieListViewModel {
        CookieListViewModel(searchOptionsViewModel: searchOptionsViewModelStub, cookiesFetcher: cookiesFetcherStub, cookiesSearcher: cookiesSearcherStub, searchResultsCalculator: calculatorStub)
    }
    
    public func makeSUTWithStubbedCookies() -> CookieListViewModel {
        let cookie1 = makeSimpleCookie(namePropertyValue: "c_name_1", valuePropertyValue: "c_value_1")
        let cookie2 = makeSimpleCookie(namePropertyValue: "c_name_2", valuePropertyValue: "c_value_2")
        cookiesFetcherStub.stubbedCookies = [cookie1, cookie2]
        return makeSUT()
    }
    
    public func makeSimpleCookie(namePropertyValue: String, valuePropertyValue: String) -> Cookie {
        let cookieFields = [
            CookieAttribute(name: HTTPCookiePropertyKey.name, value: namePropertyValue),
            CookieAttribute(name: HTTPCookiePropertyKey.value, value: valuePropertyValue)
        ]
        return Cookie(fields: cookieFields)
    }
    
    func makeSUTInSearchMode() -> CookieListViewModel {
        let sut = makeSUTWithStubbedCookies()
        
        sut.onViewDidLoad()
        sut.onBeginSearch()
        
        return sut
    }
    
    func makeSUTInSearchModeWith(searchText: String?, selectedSearchToken: HTTPCookiePropertyKey?) -> CookieListViewModel {
        let sut = makeSUTWithStubbedCookies()
        
        sut.onViewDidLoad()
        sut.onBeginSearch()
        sut.onSearchCriteriaDidChange(text: searchText, token: selectedSearchToken)
        
        return sut
    }

}

// MARK: Stubs

class CookiesFetcherStub: CookiesFetcher {
    
    var numberOfCalls = 0
    var stubbedCookies = [Cookie]()
    
    func execute(completion: @escaping ([Cookie])->Void) {
        numberOfCalls += 1
        completion(stubbedCookies)
    }
}

class CookiesSearcherStub: CookiesSearcher {
    
    enum Action: Equatable {
        case action(cookies: [Cookie], field: HTTPCookiePropertyKey?, text: String, caseOptions: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions)
    }
    
    var actions = [Action]()
    
    var stubbedSearchResult: SearchResults<Cookie> = .init(items: [])
    
    func execute(with text: String,
                 in cookies: [Cookie],
                 cookieAttribute: HTTPCookiePropertyKey?,
                 caseOption: SearchCaseSensitivityOptions,
                 wrappingOptions: SearchWordWrappingOptions) -> SearchResults<Cookie>
    {
        actions.append(.action(cookies: cookies,
                               field: cookieAttribute,
                               text: text,
                               caseOptions: caseOption,
                               wrappingOptions: wrappingOptions))
        return stubbedSearchResult
    }
    
}

class SearchOptionsViewModelStub: SearchOptionsViewModel {
    
    enum Action: Equatable {
        case setNumberOfMatches(number: Int)
    }
    
    var actions = [Action]()
    
    override func set(numberOfMatches: Int) {
        actions.append(.setNumberOfMatches(number: numberOfMatches))
    }
    
}

class CalculatorStub: SearchResultsCalculator<Cookie> {
    
    var stubbedNumberOfMatches: Int = 0
    var stubbedCalculatedItem: CalculatedItem!
    
    override func numberOfMatches(in results: SearchResults<Cookie>) -> Int {
        stubbedNumberOfMatches
    }
    
    override func item(at index: Int, in searchResults: SearchResults<Cookie>) throws -> CalculatedItem {
        stubbedCalculatedItem
    }
    
}
