//
//  DefaultCookiesSearcher.swift
//  WebInspector
//
//  Created by Robert on 30.06.2022.
//

import Foundation

class DefaultCookiesSearcher: CookiesSearcher {
    
    private let textSearcher: TextSearcher
    
    init(textSearcher: TextSearcher) {
        self.textSearcher = textSearcher
    }
    
    func execute(with text: String,
                 in cookies: [Cookie],
                 cookieAttribute: HTTPCookiePropertyKey?,
                 caseOption: SearchCaseSensitivityOptions,
                 wrappingOptions: SearchWordWrappingOptions) -> SearchResults<Cookie>
    {
        var results = [SearchResults<Cookie>.Item]()
        
        for cookie in cookies {
            for attribute in selectAttributes(by: cookieAttribute, cookie: cookie) {
                let result = textSearcher.execute(string: text, in: attribute.value, caseOption: caseOption, wrappingOptions: wrappingOptions)
                
                if !result.isEmpty {
                    results.append(.init(item: cookie, key: attribute.name.rawValue, ranges: result))
                }
            }
            
        }
        return .init(items: results)
    }
    
    private func selectAttributes(by name: HTTPCookiePropertyKey?, cookie: Cookie) -> [CookieAttribute] {
        if let name = name  {
            return cookie.attributes.filter { $0.name == name }
        } else {
            return cookie.attributes
        }
        
    }
    
}
