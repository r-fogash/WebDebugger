//
//  LogListAssembly.swift
//  WebInspector
//
//  Created by Robert on 04.07.2022.
//

import UIKit
import Swinject

class LogListAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container
            .register(LogListViewController.self) { (r: Resolver, navigationDelegate: DefaultHeaderDescriptionOpenerDelegate) in
                let viewController = LogListViewController()
                viewController.viewModel = r.resolve(LogsViewModel.self, argument: navigationDelegate)!
                return viewController
            }
            .inObjectScope(.transient)
        
        container
            .register(LogsViewModel.self) { (r: Resolver, navigationDelegate: DefaultHeaderDescriptionOpenerDelegate) in
                LogsViewModel(headerDescriptionOpener: r.resolve(HeaderDescriptionOpener.self, argument: navigationDelegate)!,
                              logger: r.resolve(WebActionsLogger.self)!)
            }
            .inObjectScope(.transient)
        
        container
            .register(HeaderDescriptionOpener.self) { (r: Resolver, navigationDelegate: DefaultHeaderDescriptionOpenerDelegate) in
                DefaultHeaderDescriptionOpener(navigationDelegate: navigationDelegate)
            }
            .inObjectScope(.transient)
    }
    
}
