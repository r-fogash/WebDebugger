//
//  CookieListAssembly.swift
//  WebInspector
//
//  Created by Robert on 29.06.2022.
//

import UIKit
import Swinject
import WebKit

class CookieListAssembly: Assembly {
    func assemble(container: Container) {
        
        container
            .register(CookieListViewController.self) { r in
                let bundle = Bundle(for: HTMLInspectorViewController.self)
                let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                let viewController = storyboard.instantiateViewController(withIdentifier: "CookieListViewController") as! CookieListViewController
                viewController.viewModel = r.resolve(CookieListViewModel.self)!
                viewController.textFormatter = r.resolve(TextFormatter.self)!
                return viewController
            }
            .inObjectScope(.transient)
        
        container
            .register(CookiesSearcher.self) { r in
                DefaultCookiesSearcher(textSearcher: r.resolve(TextSearcher.self)!)
            }
            .inObjectScope(.transient)
        
        container
            .register(CookiesFetcher.self) { r in
                WebKitCookiesFetcher(cookieStore: r.resolve(WKWebsiteDataStore.self)!.httpCookieStore)
            }
            .inObjectScope(.transient)
        
        container
            .register(CookieListViewModel.self) { r in
                CookieListViewModel(searchOptionsViewModel:r.resolve(SearchOptionsViewModel.self)!,
                                 cookiesFetcher: r.resolve(CookiesFetcher.self)!,
                                 cookiesSearcher: r.resolve(CookiesSearcher.self)!,
                                 searchResultsCalculator: r.resolve(SearchResultsCalculator<Cookie>.self)!)
            }
            .inObjectScope(.transient)
        
        container
            .register(SearchResultsCalculator<Cookie>.self) { r in
                SearchResultsCalculator<Cookie>()
            }
            .inObjectScope(.transient)
    }
}
