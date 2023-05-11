//
//  CookiesViewModel_expandAndCollapseTests.swift
//  WebInspectorTests
//
//  Created by Robert on 03.07.2022.
//

import XCTest
@testable import WebInspector

class CookiesViewModel_expandAndCollapseTests: CookieListViewModelTest_base {

    func test_givenItemCollapsed_touchItem_shouldExpandItem() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        
        sut.onTouch(item: sut.dataSnapshot.rootItems[0])
        
        XCTAssertTrue(sut.dataSnapshot.isExpanded(sut.dataSnapshot.items[0]))
    }
    
    func test_givenItemExpanded_onTouchItem_shouldCollapse() {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        
        sut.onTouch(item: sut.dataSnapshot.rootItems[0])
        sut.onTouch(item: sut.dataSnapshot.rootItems[0])
        
        XCTAssertFalse(sut.dataSnapshot.isExpanded(sut.dataSnapshot.items[0]))
    }
    
    func test_onTouchChildItem_shouldNotExpandChildItem() throws {
        let sut = makeSUTWithStubbedCookies()
        sut.onViewDidLoad()
        
        let rootItem = sut.dataSnapshot.rootItems[0]
        let childItem = try XCTUnwrap(sut.dataSnapshot.items.first { sut.dataSnapshot.parent(of: $0) == rootItem })
        
        sut.onTouch(item: childItem)
        
        XCTAssertFalse(sut.dataSnapshot.isExpanded(childItem))
    }

}
