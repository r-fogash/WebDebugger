//
//  Cookie.swift
//  WebInspector
//
//  Created by Robert on 30.06.2022.
//

import Foundation

/*
 Possible attributes
 + version
 + value
 + expiresDate
 + isSessionOnly
 + domain
 + path
 + isSecure
 + isHTTPOnly
 + comment
 + commentURL
 + portList
 */

struct Cookie: Hashable, Equatable {
    
    let attributes: [CookieAttribute]
    
    init?(cookie: HTTPCookie) {
        guard let properties = cookie.properties else {
            return nil
        }
        
        func addCookieItem(property: HTTPCookiePropertyKey, value: Any) -> CookieAttribute {
            if let stringValue = value as? String {
                return CookieAttribute(name: property, value: stringValue)
            }
            else if let urlValue = value as? URL {
                return CookieAttribute(name: property, value: urlValue.absoluteString)
            }
            else if let dateValue = value as? Date {
                return CookieAttribute(name: property, value: "DATE VALUE")
            }
            else {
                return CookieAttribute(name: property, value: "\(value)")
            }
        }
        
        attributes = properties.map { (key: HTTPCookiePropertyKey, value: Any) in
            addCookieItem(property: key, value: value)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        attributes.forEach{ hasher.combine($0) }
    }
    
    init(fields: [CookieAttribute]) {
        self.attributes = fields
    }
}
