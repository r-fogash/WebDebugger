//
//  WebView.swift
//  WebInspectorTests
//
//  Created by Robert on 27.05.2022.
//

import Foundation
@testable import WebInspector

typealias FetchNodesCompletion = (Any?, Error?) -> Void

class WebViewStub: WebView {
    enum Action: Equatable {
        case loadUrl(URL)
        case evaluateJS(String)
    }
    var actions = [Action]()
    var evaluateJSCompletionHandler: ((FetchNodesCompletion) -> Void)?
    
    func load(url: URL) {
        actions.append(.loadUrl(url))
    }
    
    func evaluate(js: String, completion: @escaping FetchNodesCompletion) {
        actions.append(.evaluateJS(js))
        evaluateJSCompletionHandler?(completion)
    }
}
