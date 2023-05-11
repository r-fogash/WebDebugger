//
//  DefaultHTMLNodesExtractorTests.swift
//  WebInspectorTests
//
//  Created by Robert on 27.05.2022.
//

import XCTest
import Combine
@testable import WebInspector
import WebKit

class DefaultHTMLNodesExtractorTests: XCTestCase {

    var webView: WebViewStub!
    var bag = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        webView = WebViewStub()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        bag.removeAll()
        webView = nil
    }

    func test_onStart_injectJavascript() throws {
        let sut = makeSUT()

        sut.execute().sink { _ in } receiveValue: { _ in }.store(in: &bag)
        
        let js = try loadJSScript()
        XCTAssertEqual(webView.actions, [.evaluateJS(js)])
    }
    
    func test_webView_didFetchOneRawHTMLNode_showInspectorWithConvertedOneNode() {
        let sut = makeSUT()
        let rawHTMLNode = ["html" : "<body></body>"]
        
        webView.evaluateJSCompletionHandler = { completion in
            completion(rawHTMLNode, nil)
        }
        
        let expectation = expectation(description: "parse HTML")
        sut.execute().sink { output in
            switch output {
            case .failure(let error):
                XCTFail("expected to get parsed node")
            default: break
            }
            expectation.fulfill()
        } receiveValue: { node in
            XCTAssertEqual(node.text, rawHTMLNode["html"])
            XCTAssertTrue(node.child.isEmpty)
        }.store(in: &bag)

        wait(for: [expectation], timeout: 1)
    }
    
    @MainActor
    func test_js() throws {
        let navigationDelegate = WKNavigationDelegateImpl()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 900))
        webView.navigationDelegate = navigationDelegate
        let js = try loadJSScript()
        let html =
"""
<html>
<head>
</head>
<body>
some body text
</body>
</html>
"""
        let expectation = expectation(description: "evaluate js")
        
        navigationDelegate.completion = {
            webView.evaluateJavaScript(js, completionHandler: { res, error in
                XCTAssertTrue(res is RawHTMLNode)
                
                let expected = NSMutableDictionary()
                expected["html"] = "<html></html>"
                expected["children"] = [
                    [
                        "html" : "<head></head>",
                    ] as! [String: AnyHashable],
                    [
                        "html" : "<body></body>",
                        "children" : [
                            ["html" : "some body text"]
                        ]
                    ]
                ]
                XCTAssertEqual((res as! NSDictionary), expected)
                expectation.fulfill()
            })
        }
        
        webView.loadHTMLString(html, baseURL: nil)
                                                           
        wait(for: [expectation], timeout: 10)
    }
    
    func test_ableToExtractAttributes() throws {
        let navigationDelegate = WKNavigationDelegateImpl()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 900))
        webView.navigationDelegate = navigationDelegate
        let js = try loadJSScript()
        let html =
"""
<html>
<head>
</head>
<body someKey="some value" otherKey="other value">
some body text
</body>
</html>
"""
        let expectation = expectation(description: "evaluate js")
        
        navigationDelegate.completion = {
            webView.evaluateJavaScript(js, completionHandler: { res, error in
                XCTAssertTrue(res is RawHTMLNode)
                
                let expected = NSMutableDictionary()
                expected["html"] = "<html></html>"
                expected["children"] = [
                    [
                        "html" : "<head></head>",
                    ] as! [String: AnyHashable],
                    [
                        "html" : "<body somekey=\"some value\" otherkey=\"other value\"></body>",
                        "attributes" : [
                            "somekey" : "some value",
                            "otherkey" : "other value"
                        ],
                        "children" : [
                            ["html" : "some body text"]
                        ]
                    ]
                ]
                XCTAssertEqual((res as! NSDictionary), expected)
                expectation.fulfill()
            })
        }
        
        webView.loadHTMLString(html, baseURL: nil)
                                                           
        wait(for: [expectation], timeout: 10)
    }

}

class WKNavigationDelegateImpl: NSObject, WKNavigationDelegate {
    
    var completion: ( ()->Void )?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        completion?()
    }
    
}

extension DefaultHTMLNodesExtractorTests {
    
    func makeSUT() -> DefaultHTMLNodesExtractor {
        DefaultHTMLNodesExtractor(webView: webView)
    }
    
    func loadJSScript() throws -> String {
        let bundle = Bundle(for: AppDelegate.classForCoder())
        let url = bundle.url(forResource: "fetch_dom.js", withExtension: nil)!
        return try String(contentsOf: url)
    }
    
}
