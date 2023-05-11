//
//  BrowserViewControllerTests.swift
//  BrowserViewControllerTests
//
//  Created by Robert on 26.05.2022.
//

import XCTest
@testable import WebInspector
import WebKit

class BrowserViewControllerTests: XCTestCase {
    
    var coordinator: CoordinatorStub!
    var loggerStub: WebActionsLoggerStub!
    var loadUrlString: LoadUrlStringStub!
    var browserViewModel: BrowserViewModelSpy!
    
    override func setUpWithError() throws {
        loggerStub = WebActionsLoggerStub()
        coordinator = CoordinatorStub()
        loadUrlString = LoadUrlStringStub()
        browserViewModel = BrowserViewModelSpy()
    }

    override func tearDownWithError() throws {
        coordinator = nil
        loggerStub = nil
        loadUrlString = nil
        browserViewModel = nil
    }
    
    // MARK: Initial state
    
    func test_onCreate_InfoDisabled() {
        XCTAssertFalse(makeSUT().info.isEnabled)
    }
    
    func test_onCreate_reloadDisabled() {
        XCTAssertFalse(makeSUT().reloadButton.isEnabled)
    }
    
    func test_onCreate_navigationControlsDisabled() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.webBackButton.isEnabled)
        XCTAssertFalse(sut.webForwardButton.isEnabled)
    }
    
    // MARK: Info button behaviour
    
    func test_whenLoading_infoDisabled() {
        let sut = makeSUT()
        sut.setPageDidStartLoading()
        
        XCTAssertFalse(sut.info.isEnabled)
        
        sut.setPageDidFinishLoading()
        sut.setPageDidStartLoading()
        
        XCTAssertFalse(sut.info.isEnabled)
    }
    
    func test_whenFinishLoad_infoEnabled() {
        let sut = makeSUT()
        sut.setPageDidFinishLoading()
        
        XCTAssertTrue(sut.info.isEnabled)
    }
    
    func test_onTouchInfo_callViewModel() {
        let sut = makeSUT()
        sut.onInfo(UIBarButtonItem())
        
        XCTAssertEqual(browserViewModel.actions, [.onInfo])
    }
    
    // MARK: Reload button behavior
    
    func test_whenLoading_reloadEnabled() {
        let sut = makeSUT()
        sut.setPageDidStartLoading()
        
        XCTAssertTrue(sut.reloadButton.isEnabled)
    }
    
    func test_whenFinishLoad_reloadButtonEnabled() {
        let sut = makeSUT()
        sut.setPageDidStartLoading()
        sut.setPageDidFinishLoading()
        
        XCTAssertTrue(sut.reloadButton.isEnabled)
    }
    
    // MARK: Enter url address
    
    func test_commitEnteredUrlAddress_callLoad() {
        let sut = makeSUT()
        
        let urlString = "http://google.com"
        sut.addressTextField.text = urlString
        sut.commitAddressTextField()
        
        XCTAssertEqual(browserViewModel.actions, [.loadUrlString(argument: urlString)])
    }
    
    // MARK: reload behaviour
    
    func test_onReload_callViewModel() {
        let sut = makeSUT()
        
        sut.reload(UIBarButtonItem())
        
        XCTAssertEqual(browserViewModel.actions, [.onReload])
    }
    
    // MARK: navigation controls behavior
    
    func test_pageLoaded_noWebHistory_navigationButtonsDisabled() throws {
        let url = try url(for: "TestPage1.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url)])
        
        XCTAssertFalse(sut.webBackButton.isEnabled)
        XCTAssertFalse(sut.webForwardButton.isEnabled)
    }
    
    func test_browserHasBackHistory_backButtonEnabled() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2)])
        
        XCTAssertTrue(sut.webBackButton.isEnabled)
        XCTAssertFalse(sut.webForwardButton.isEnabled)
    }
    
    func test_browserHasForwardHistory_forwardButtonEnabled() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2), .goBack])
        
        XCTAssertTrue(sut.webForwardButton.isEnabled)
    }
    
    func test_backNavigation() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2), .goBack])
        
        XCTAssertEqual(sut.webView.url, url1)
    }
    
    func test_forwardNavigation() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2), .goBack, .goForward])
        
        XCTAssertEqual(sut.webView.url, url2)
    }
    
    // MARK: Logging
    
    func test_onMakingRequest_logRequest() {
        let sut = makeSUT()
        
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let navigationAction = WKNavigationActionStub(request: request)
        let decisionHandler = { (policy: WKNavigationActionPolicy) in  }
        
        (sut as WKNavigationDelegate).webView?(sut.webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
        XCTAssertEqual(loggerStub.loggerActions, [.logAction(.request(request))])
    }
    
    func test_onHandlingResponse_logResponse() {
        let sut = makeSUT()
        
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1", headerFields: ["A" : "B"])!
        let navigationResponse = WKNavigationResponseStub(response: urlResponse)
        let decisionHandler = { (responsePolicy: WKNavigationResponsePolicy) in  }
        
        (sut as WKNavigationDelegate).webView?(sut.webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler)
        
        XCTAssertEqual(loggerStub.loggerActions, [.logAction(.response(urlResponse))])
    }
    
    func test_reload_logReloadUserAction() {
        let sut = makeSUT()
        
        sut.touchReload()
        
        XCTAssertEqual(loggerStub.loggerActions, [.logAction(.userAction("reload"))])
    }
    
    func test_goBack_loadNavigateBackUserAction() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2)])
        sut.touchBack()
        
        let request = URLRequest(url: url1)
        let response = HTTPURLResponse(url: url1, statusCode: 200, httpVersion: "1", headerFields: nil)!
        
        
        let expectedActions: [WebActionsLoggerStub.Action] = [
            .logAction(.request(request)),
            .logAction(.response(response)),
            .logAction(.request(request)),
            .logAction(.response(response)),
            .logAction(.userAction("navigateBack"))
        ]
        
        assertEqualActionsIgnoreRequestAndResponseArguments(actions: loggerStub.loggerActions, otherActions: expectedActions)
    }
    
    func test_goForward_logNavigationForwardUserAction() throws {
        let url1 = try url(for: "TestPage1.html")
        let url2 = try url(for: "TestPage2.html")
        
        let sut = try makeSUT(webViewNavigationCommands: [.load(url1), .load(url2)])
        
        let goBackExpectation = sut.makeExpectationWebViewIsLoading(false, testCase: self)
        sut.touchBack()
        wait(for: [goBackExpectation], timeout: 1)
        
        let goForwardExpectation = sut.makeExpectationWebViewIsLoading(false, testCase: self)
        sut.touchFormward()
        wait(for: [goForwardExpectation], timeout: 1)
        
        let request = URLRequest(url: url1)
        let response = HTTPURLResponse(url: url1, statusCode: 200, httpVersion: "1", headerFields: nil)!
        
        
        let expectedActions: [WebActionsLoggerStub.Action] = [
            .logAction(.request(request)),
            .logAction(.response(response)),
            .logAction(.request(request)),
            .logAction(.response(response)),
            .logAction(.userAction("navigateBack")),
            .logAction(.request(request)),
            .logAction(.userAction("navigationForward")),
            .logAction(.request(request)),
        ]
        
        assertEqualActionsIgnoreRequestAndResponseArguments(actions: loggerStub.loggerActions, otherActions: expectedActions)
    }
     
    func assertEqualActionsIgnoreRequestAndResponseArguments(actions:[WebActionsLoggerStub.Action], otherActions:[WebActionsLoggerStub.Action]) {
        XCTAssertEqual(actions.count, otherActions.count)
        
        let firstActions = actions.map { loggedAction -> LoggerAction in
            switch loggedAction {
            case .logAction(let act): return act
            }
        }
        let secondActions = otherActions.map { loggedAction -> LoggerAction in
            switch loggedAction {
            case .logAction(let act): return act
            }
        }
        
        for (firstAction, secondAction) in zip(firstActions, secondActions) {
            switch (firstAction, secondAction) {
            case (.request(_), .request(_)) : continue
            case (.response(_), .response(_)): continue
            default:
                if firstAction == secondAction { continue }
                else { XCTFail("\(firstAction) is not equal to \(secondAction)") }
            }
        }
    }

}

class WKNavigationActionStub: WKNavigationAction {
    private let internalRequest: URLRequest
    override var request: URLRequest {
        internalRequest
    }
    
    init(request: URLRequest) {
        internalRequest = request
    }
}

class WKNavigationResponseStub: WKNavigationResponse {
    private let internalResponse: HTTPURLResponse
    override var response: URLResponse {
        internalResponse
    }
    
    init(response: HTTPURLResponse) {
        internalResponse = response
    }
}

extension BrowserViewControllerTests {
    
    enum WebViewNavigationCommand {
        case load(URL)
        case goForward
        case goBack
    }
    
    func makeSUT() -> BrowserViewController {
        let bundle = Bundle(for: BrowserViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let browserViewController = storyboard.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        
        browserViewController.datastore = WKWebsiteDataStore.default()
        browserViewController.webLogger = loggerStub
        browserViewController.viewModel = browserViewModel
        
        browserViewController.beginAppearanceTransition(true, animated: false)
        return browserViewController
    }
    
    enum SUTNavigationError: Error {
        case cannotGoBack
        case cannotGoForward
    }
    
    func makeSUT(webViewNavigationCommands: [WebViewNavigationCommand]) throws -> BrowserViewController {
        let sut = makeSUT()
        
        for command in webViewNavigationCommands {
            let expectation = sut.makeExpectationWebViewIsLoading(false, testCase: self)
            
            switch command {
            case .load(let url):
                sut.load(url: url)
            case .goForward:
                guard sut.webView.canGoForward else {
                    throw SUTNavigationError.cannotGoForward
                }
                sut.webView.goForward()
            case .goBack:
                guard sut.webView.canGoBack else {
                    throw SUTNavigationError.cannotGoBack
                }
                sut.webView.goBack()
            }
            wait(for: [expectation], timeout: 1)
        }
        
        return sut
    }
    
    func url(for resource: String) throws -> URL {
        try XCTUnwrap(testBundle().url(forResource: resource, withExtension: nil))
    }
    
    func testBundle() -> Bundle {
        Bundle(for: BrowserViewControllerTests.classForCoder())
    }
    
}

extension BrowserViewController {
 
    static let navigation = WKNavigation()
    
    func setPageDidStartLoading() {
        webView(webView, didStartProvisionalNavigation: Self.navigation)
    }
    
    func setPageDidFinishLoading() {
        webView(webView, didFinish: Self.navigation)
    }
    
    func enterURLAddress(_ address: String) {
        addressTextField.text = address
    }
    
    func commitAddressTextField() {
        let _ = textFieldShouldReturn(addressTextField)
    }
    
    func touchReload() {
        let _ = reloadButton.target?.perform(reloadButton.action, with: reloadButton)
    }
    
    func touchBack() {
        back(webBackButton)
    }
    
    func touchFormward() {
        forward(webForwardButton)
    }
    
    // Unit tests
    func makeExpectationWebViewIsLoading(_ isLoading: Bool, testCase: XCTestCase) -> XCTestExpectation {
        testCase.keyValueObservingExpectation(for: webView!, keyPath: #keyPath(WKWebView.isLoading)) { _, change in
            change[NSKeyValueChangeKey.newKey] as? Bool == isLoading
        }
    }
}
