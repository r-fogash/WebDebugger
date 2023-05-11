//
//  HTMLInspectorAssembly.swift
//  WebInspector
//
//  Created by Robert on 26.06.2022.
//

import UIKit
import Swinject
import WebKit

class HTMLInspectorAssembly: Assembly {
    
    func assemble(container: Container) {
        container
            .register(HTMLInspectorViewController.self) { (r: Resolver, htmlNode: HTMLNode, navigationDelegate: HTMLInspectorNavigationDelegate) in
                
                let bundle = Bundle(for: HTMLInspectorViewController.self)
                let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                let viewController = storyboard.instantiateViewController(withIdentifier: "HTMLInspectorViewController") as! HTMLInspectorViewController
                
                viewController.textFormatter = r.resolve(TextFormatter.self)!
                viewController.viewModel = r.resolve(HTMLInspectorViewModel.self, arguments: htmlNode, navigationDelegate)!
                
                return viewController
            }
            .inObjectScope(.transient)
        
        container
            .register(HTMLInspectorViewModel.self) { (r: Resolver, htmlNode: HTMLNode, navigationDelegate: HTMLInspectorNavigationDelegate) in
                HTMLInspectorViewModel(htmlNode: htmlNode,
                                       searchNodes: r.resolve(HTMLNodesSearcher.self)!,
                                       searchOptionsViewModel: r.resolve(SearchOptionsViewModel.self)!,
                                       searchResultsCalculator: r.resolve(SearchResultsCalculator<HTMLNode>.self)!,
                                       navigationDelegate: navigationDelegate)
            }
            .inObjectScope(.transient)
        
        container
            .register(TextFormatter.self) { r in
                DefaultTextFormatter()
            }
            .inObjectScope(.transient)
        
        container
            .register(TextSearcherContainsStrategy.self) { r in
                TextSearcherContainsStrategy()
            }
            .inObjectScope(.transient)
        
        container
            .register(TextSearchMatchWordStrategy.self) { r in
                TextSearchMatchWordStrategy()
            }
            .inObjectScope(.transient)
        
        container
            .register(TextSearcher.self) { r in
                DefaultTextSearcher(wordContainsStrategy: r.resolve(TextSearcherContainsStrategy.self)!,
                             wordMatchStrategy: r.resolve(TextSearchMatchWordStrategy.self)!)
            }
            .inObjectScope(.transient)
        
        container
            .register(HTMLNodesSearcher.self) { r in
                HTMLNodesSearcher(textSearcher: r.resolve(TextSearcher.self)!)
            }
            .inObjectScope(.transient)
        
        container
            .register(SearchResultsCalculator<HTMLNode>.self) { r in
                SearchResultsCalculator<HTMLNode>()
            }
            .inObjectScope(.transient)
        
        container
            .register(SearchOptionsViewModel.self) { r in
                DefaultSearchOptionsViewModel()
            }
            .inObjectScope(.transient)
    }
    
}
