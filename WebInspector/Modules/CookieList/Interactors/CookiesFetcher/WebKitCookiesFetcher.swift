//
//  WebKitCookiesFetcher.swift
//  WebInspector
//
//  Created by Robert on 01.07.2022.
//

import Foundation
import WebKit

class WebKitCookiesFetcher: CookiesFetcher {
    
    private let cookieStore: WKHTTPCookieStore
    
    init(cookieStore: WKHTTPCookieStore) {
        self.cookieStore = cookieStore
    }
    
    func execute(completion: @escaping ([Cookie]) -> Void) {
        cookieStore.getAllCookies { (cookies: [HTTPCookie]) in
            completion(cookies.compactMap { Cookie(cookie: $0) })
        }
    }
    
}
