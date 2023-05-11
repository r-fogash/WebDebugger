//
//  CoordinatorAssembly.swift
//  WebInspector
//
//  Created by Robert on 26.06.2022.
//

import UIKit
import Swinject

class CoordinatorAssembly: Assembly {
    func assemble(container: Container) {
        container
            .register(Coordinator.self) { r in
                
                let dependencies = RootCoordinator.Dependencies { navigationDelegate in
                    r.resolve(BrowserViewController.self, argument: navigationDelegate)!
                } makeHTMLInspectorScene: { (htmlNode: HTMLNode, navigationDelegate: HTMLInspectorNavigationDelegate) -> UIViewController in
                    r.resolve(HTMLInspectorViewController.self, arguments: htmlNode, navigationDelegate)!
                } makeCookiesScene: {
                    r.resolve(CookieListViewController.self)!
                } makeLogsScene: { navigationDelegate in
                    r.resolve(LogListViewController.self, argument: navigationDelegate)!
                }
                
                return RootCoordinator(dependencies: dependencies, window: r.resolve(UIWindow.self)!)
            }
            .inObjectScope(.transient)
    }
}
