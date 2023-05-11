//
//  Cookie+name.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import Foundation

extension Cookie {
    var name: String {
        attributes.first { $0.name == HTTPCookiePropertyKey.name }!.value
    }
}
