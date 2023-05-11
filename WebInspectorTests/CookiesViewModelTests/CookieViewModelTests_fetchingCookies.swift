//
//  CookieViewModelTests_fetchingCookies.swift
//  WebInspectorTests
//
//  Created by Robert on 03.07.2022.
//

import XCTest
@testable import WebInspector

class CookieViewModelTests_fetchingCookies: CookieListViewModelTest_base {

    func test_onViewDidLoad_fetchCookies() {
        let sut = makeSUT()
        sut.onViewDidLoad()
        XCTAssertEqual(cookiesFetcherStub.numberOfCalls, 1)
    }
    
    func test_whenDidFetchCookies_sectionSnapshotContainsCookies() {
        let sut = makeSUT()
        
        let cookie = makeSimpleCookie(namePropertyValue: "cookie_name", valuePropertyValue: "cookie_value")
        cookiesFetcherStub.stubbedCookies = [cookie]
        
        sut.onViewDidLoad()
        
        let cookieItem = CookieItemModel(cookie: cookie, isHeader: true)
        let cookieSubItem = CookieItemModel(cookie: cookie, isHeader: false)
        
        XCTAssertEqual(sut.dataSnapshot.items, [cookieItem, cookieSubItem])
        XCTAssertEqual(sut.dataSnapshot.parent(of: cookieSubItem), cookieItem)
    }
    
    func test_whenDidFetchCookies_allCookiesInDatasourceIsCollapsed() {
        let sut = makeSUT()
        let cookie1 = makeSimpleCookie(namePropertyValue: "c_name_1", valuePropertyValue: "c_value_1")
        let cookie2 = makeSimpleCookie(namePropertyValue: "c_name_2", valuePropertyValue: "c_value_2")
        cookiesFetcherStub.stubbedCookies = [cookie1, cookie2]
        
        sut.onViewDidLoad()
        
        XCTAssertFalse(sut.dataSnapshot.isExpanded(.init(cookie: cookie1, isHeader: true)))
        XCTAssertFalse(sut.dataSnapshot.isExpanded(.init(cookie: cookie2, isHeader: true)))
    }

}
