//
//  CookieItemModel.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import Foundation

struct CookieItemModel: Hashable, Equatable {
    let cookie: Cookie
    let isHeader: Bool
    private(set) var searchResults: [String:[Range<String.Index>]]
    
    init(cookie: Cookie, isHeader: Bool) {
        self.cookie = cookie
        self.isHeader = isHeader
        self.searchResults = [:]
    }
    
    init(cookie: Cookie, isHeader: Bool, searchResults: [String : [Range<String.Index>]]) {
        self.cookie = cookie
        self.isHeader = isHeader
        self.searchResults = searchResults
    }
    
    mutating func append(searchResults: [String : [Range<String.Index>]]) {
        self.searchResults = self.searchResults.merging(searchResults, uniquingKeysWith: { val1, val1 in
            val1
        })
    }
}
