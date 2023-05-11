//
//  WebBrowserAssembly.swift
//  WebInspector
//
//  Created by Robert on 26.06.2022.
//

import UIKit
import Swinject
import WebKit

class WebBrowserAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container
            .register(WKWebsiteDataStore.self) { r in
                WKWebsiteDataStore.default()
            }
            .inObjectScope(.transient)
        
        container
            .register(URLStringRefiner.self) { r in
                DefaultURLStringRefiner()
            }
            .inObjectScope(.transient)
        
        container
            .register(HTMLNodesExtractor.self) { (r: Resolver, webView: WebView) in
                DefaultHTMLNodesExtractor(webView: webView)
            }
            .inObjectScope(.transient)
        
        container
            .register(WebActionsLogger.self) { r in
                DefaultWebActionsLogger()
            }
            .inObjectScope(.container)
        
        container
            .register(BrowserViewModel.self) { (r: Resolver, htmlNodesExtractor: HTMLNodesExtractor, navigationDelegate: BrowserViewModelNavigation) in
                DefaultBrowserViewModel(htmlNodesExtractor: htmlNodesExtractor,
                                        urlStringRefiner: r.resolve(URLStringRefiner.self)!,
                                        navigationDelegate: navigationDelegate)
            }
            .inObjectScope(.transient)
        
        container
            .register(BrowserViewController.self) { (r: Resolver, navigationDelegate: BrowserViewModelNavigation) in
                let bundle = Bundle(for: BrowserViewController.self)
                let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                let vc = storyboard.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                
                let htmlNodesExtractor = r.resolve(HTMLNodesExtractor.self, argument: vc as WebView)!
                let viewModel = r.resolve(BrowserViewModel.self, arguments: htmlNodesExtractor, navigationDelegate)!
                
                vc.viewModel = viewModel
                vc.datastore = r.resolve(WKWebsiteDataStore.self)!
                vc.webLogger = r.resolve(WebActionsLogger.self)!
                
                return vc
            }
    }
    
}
