//
//  CoordinatorStub.swift
//  WebInspectorTests
//
//  Created by Robert on 27.05.2022.
//

import Foundation
@testable import WebInspector

class CoordinatorStub: Coordinator {
    
    enum Action: Equatable {
        case start
        case showErrorMessage(String)
        case showHTMLInspector(HTMLNode)
        case showCookies
        case showLogs
        case openURL(URL)
    }
    
    var actions = [Action]()
    
    func start() {
        actions.append(.start)
    }
    func showError(message: String) {
        actions.append(.showErrorMessage(message))
    }
    func showHTMLInspector(node: HTMLNode) {
        actions.append(.showHTMLInspector(node))
    }
    func showCookies() {
        actions.append(.showCookies)
    }
    func showLogs() {
        actions.append(.showLogs)
    }
    func open(url: URL) {
        actions.append(.openURL(url))
    }
}
