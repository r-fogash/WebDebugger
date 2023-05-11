//
//  CookieAttribute.swift
//  WebInspector
//
//  Created by Robert on 30.06.2022.
//

import Foundation

struct CookieAttribute: Equatable, Hashable {
    let name: HTTPCookiePropertyKey
    let value: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }
}
