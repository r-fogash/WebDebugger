//
//  DefaultHTMLNodesExtractor.swift
//  WebInspector
//
//  Created by Robert on 25.05.2022.
//

import Foundation
import Combine

struct HTMLNodesExtractorInternalError: Error, LocalizedError {
    var errorDescription: String? {
        "Unknown parsing error"
    }
}

class DefaultHTMLNodesExtractor: HTMLNodesExtractor {
    
    private weak var webView: WebView?
    
    private var js: String {
        let url = Bundle.main.url(forResource: "fetch_dom.js", withExtension: nil)!
        return try! String(contentsOf: url)
    }
    
    init(webView: WebView) {
        self.webView = webView
    }
    
    func execute() -> Future<HTMLNode, Error> {
        .init { [unowned self] promise in
            webView?.evaluate(js: js) { (result, error) in
                if let error {
                    promise(.failure(error))
                    return
                }

                guard let rawHTMLNode = result as? RawHTMLNode else {
                    promise(.failure(HTMLNodesExtractorInternalError()))
                    return
                }
                promise(.success(convertToHTMLNode(rawHTMLNode: rawHTMLNode)))
            }
        }
    }
    
}
