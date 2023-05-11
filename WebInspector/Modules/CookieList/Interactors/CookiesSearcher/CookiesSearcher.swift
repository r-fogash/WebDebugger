//
//  CookiesSearcher.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import Foundation

protocol CookiesSearcher {
    func execute(with text: String,
                 in cookies: [Cookie],
                 cookieAttribute: HTTPCookiePropertyKey?,
                 caseOption: SearchCaseSensitivityOptions,
                 wrappingOptions: SearchWordWrappingOptions) -> SearchResults<Cookie>
}
