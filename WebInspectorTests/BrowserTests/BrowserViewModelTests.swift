//
//  BrowserViewModelTests.swift
//  WebInspectorTests
//
//  Created by Robert on 08.05.2023.
//

import XCTest
import Combine
@testable import WebInspector

final class BrowserViewModelTests: XCTestCase {

    var htmlNodesExtractorStub: ExtractHTMLNodesStub!
    var loadUrlStringStub: LoadUrlStringStub!
    var stubNavigationDelegate: StubNavigationDelegate!
    
    let urlString = "http://stuburl.com"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        htmlNodesExtractorStub = .init()
        loadUrlStringStub = .init()
        stubNavigationDelegate = .init()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        htmlNodesExtractorStub = nil
        loadUrlStringStub = nil
        stubNavigationDelegate = nil
    }
    
    func test_onLoadUrlString_callInteractor() {
        let sut = makeSUT()
        
        sut.loadUrlString(urlString)
        
        XCTAssertEqual(loadUrlStringStub.argument, urlString)
    }
    
    func test_onReload_passNilToUrlInteractor() {
        let sut = makeSUT()
        
        sut.onReload()
        
        XCTAssertNil(loadUrlStringStub.argument)
    }
    
    func test_onReload_passPreviouslyLoadedUrlStringToInteractor() {
        let sut = makeSUT()
        sut.loadUrlString(urlString)
        sut.onReload()
        
        XCTAssertEqual(loadUrlStringStub.numberOfCallStart, 2)
        XCTAssertEqual(loadUrlStringStub.argument, urlString)
    }
    
    func test_onInfo_callExtractNodesInteractor() {
        let sut = makeSUT()
        sut.onInfo()
        
        XCTAssert(htmlNodesExtractorStub.numberOfCallStart == 1)
    }
    
    func test_onExtractNodesSuccess_callNavigationDelegate() {
        let sut = makeSUT()
        htmlNodesExtractorStub.stubbedResult = .success(HTMLNode(text: "OK", child: [], attributes: [:]))
        
        sut.onInfo()
        
        XCTAssertEqual(stubNavigationDelegate.actions, [.showInspector])
    }
    
    func test_onExtractNodesFail_showError() {
        let sut = makeSUT()
        htmlNodesExtractorStub.stubbedResult = .failure(HTMLNodesExtractorInternalError())
        
        sut.onInfo()
        
        XCTAssertEqual(stubNavigationDelegate.actions, [.showAlert(message: HTMLNodesExtractorInternalError().localizedDescription)])
    }

}

extension BrowserViewModelTests {
    
    func makeSUT() -> DefaultBrowserViewModel {
        DefaultBrowserViewModel(htmlNodesExtractor: htmlNodesExtractorStub, urlStringRefiner: loadUrlStringStub, navigationDelegate: stubNavigationDelegate)
    }
    
}


class ExtractHTMLNodesStub: HTMLNodesExtractor {
    var numberOfCallStart = 0
    var stubbedResult: Result<HTMLNode, Error> = .failure(HTMLNodesExtractorInternalError())
    
    func execute() -> Future<WebInspector.HTMLNode, Error> {
        numberOfCallStart += 1
        return .init { [unowned self] promise in
            promise(stubbedResult)
        }
    }
    
}

class LoadUrlStringStub: URLStringRefiner {
    var numberOfCallStart = 0
    var argument: String?
    var stubberResult: URL?
    
    func execute(_ urlString: String?) -> URL? {
        numberOfCallStart += 1
        argument = urlString
        return stubberResult
    }
}

class StubNavigationDelegate: BrowserViewModelNavigation {
    enum Action: Equatable {
        case showAlert(message: String)
        case showInspector
    }
    
    var actions = [Action]()
    
    func showAlert(message: String) -> Future<Int, Never> {
        actions.append(.showAlert(message: message))
        return .init { promise in
            promise(.success(0))
        }
    }
    
    func showInspector(node: HTMLNode) {
        actions.append(.showInspector)
    }
}
