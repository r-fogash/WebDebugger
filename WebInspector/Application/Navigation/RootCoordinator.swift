//
//  RootCoordinator.swift
//  WebInspector
//
//  Created by Robert on 25.05.2022.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import Combine

protocol Coordinator {
    func start()
    func showError(message: String)
}

class RootCoordinator: Coordinator {
    
    struct Dependencies {
        let makeBrowserScene: (BrowserViewModelNavigation) -> UIViewController
        let makeHTMLInspectorScene: (HTMLNode, HTMLInspectorNavigationDelegate) -> UIViewController
        let makeCookiesScene: () -> UIViewController
        let makeLogsScene: (DefaultHeaderDescriptionOpenerDelegate) -> UIViewController
    }
    
    private let dependencies: Dependencies
    private let window: UIWindow
    private var navigationStack: UINavigationController!
    
    init(dependencies: Dependencies, window: UIWindow)
    {
        self.dependencies = dependencies
        self.window = window
    }
    
    func start() {
        navigationStack = UINavigationController(rootViewController: dependencies.makeBrowserScene(self))
        window.rootViewController = navigationStack
    }
    
    private func showHTMLInspector(node: HTMLNode) {
        let viewController = dependencies.makeHTMLInspectorScene(node, self)
        navigationStack.pushViewController(viewController, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        navigationStack.present(alert, animated: true)
    }
    
    private func showCookies() {
        let viewController = dependencies.makeCookiesScene()
        navigationStack.pushViewController(viewController, animated: true)
    }
    
    private func showLogs() {
        let viewController = dependencies.makeLogsScene(self)
        navigationStack.pushViewController(viewController, animated: true)
    }
    
    private func showSafariViewController(url: URL) {
        let safariController = SFSafariViewController(url: url)
        navigationStack.present(safariController, animated: true)
    }
    
}

extension RootCoordinator: BrowserViewModelNavigation {
    func showInspector(node: HTMLNode) {
        showHTMLInspector(node: node)
    }
    
    func showAlert(message: String) -> Future<Int, Never> {
        return .init { [unowned self] promise in
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                promise(.success(0))
            }
            alertController.addAction(okAction)
            navigationStack.present(alertController, animated: true)
        }
    }
}

// MARK: HTMLInspectorNavigationDelegate

extension RootCoordinator: HTMLInspectorNavigationDelegate {
    func openCookies() {
        showCookies()
    }
    
    func openLogs() {
        showLogs()
    }
}

// MARK: DefaultHeaderDescriptionOpenerDelegate

extension RootCoordinator: DefaultHeaderDescriptionOpenerDelegate {
    func open(url: URL) {
        showSafariViewController(url: url)
    }
}
