//
//  DefaultHeaderDescriptionOpener.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import Foundation

protocol DefaultHeaderDescriptionOpenerDelegate: AnyObject {
    func open(url: URL)
}

class DefaultHeaderDescriptionOpener: HeaderDescriptionOpener {
    private weak var navigationDelegate: DefaultHeaderDescriptionOpenerDelegate?
    
    init(navigationDelegate: DefaultHeaderDescriptionOpenerDelegate) {
        self.navigationDelegate = navigationDelegate
    }
    
    func execute(_ header: String) {
        guard header.isEmpty == false else {
            return
        }
        guard let url = URL(string: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/" + header) else {
            return
        }
        navigationDelegate?.open(url: url)
    }
}
