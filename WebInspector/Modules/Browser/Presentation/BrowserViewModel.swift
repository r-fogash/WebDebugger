//
//  BrowserViewModel.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import Foundation
import Combine

class BrowserViewModel {
    let loadUrl: PassthroughSubject<URL, Never> = .init()
    
    func onInfo() { }
    func onReload() { }
    func loadUrlString(_ urlString: String?) { }
}

protocol BrowserViewModelNavigation: AnyObject {
    func showInspector(node: HTMLNode)
    func showAlert(message: String) -> Future<Int, Never>
}

class DefaultBrowserViewModel: BrowserViewModel {
    private let htmlNodesExtractor: HTMLNodesExtractor
    private let urlStringRefiner: URLStringRefiner
    
    private var bag = Set<AnyCancellable>()
    private var lastKnowUrlString: String?
    
    var navigationDelegate: BrowserViewModelNavigation?
    
    init(htmlNodesExtractor: HTMLNodesExtractor,
         urlStringRefiner: URLStringRefiner,
         navigationDelegate: BrowserViewModelNavigation)
    {
        self.htmlNodesExtractor = htmlNodesExtractor
        self.urlStringRefiner = urlStringRefiner
        self.navigationDelegate = navigationDelegate
    }
    
    override func loadUrlString(_ urlString: String?) {
        lastKnowUrlString = urlString
        loadLastKnownUrl()
    }
    
    override func onInfo() {
        htmlNodesExtractor.execute().sink { [unowned self] completion in
            switch completion {
            case .failure(let error):
                let _ = navigationDelegate?.showAlert(message: error.localizedDescription)
            default: break
            }
        } receiveValue: { [weak navigationDelegate] node in
            navigationDelegate?.showInspector(node: node)
        }.store(in: &bag)

    }
    
    override func onReload() {
        loadLastKnownUrl()
    }
    
    private func loadLastKnownUrl() {
        urlStringRefiner.execute(lastKnowUrlString)
            .flatMap { loadUrl.send($0) }
    }

}
