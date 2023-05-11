//
//  DependencyManager.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import UIKit
import Swinject

class DependencyManager {
    var container: Container
    
    init(window: UIWindow) {
        container = Container()
        container.register(UIWindow.self) { r in
            window
        }.inObjectScope(.container)
        initializeCompositionRoot()
    }
    
    func makeLaunchAppInteractor() -> LaunchAppInteractor {
        container.resolve(LaunchAppInteractor.self)!
    }
    
    private func initializeCompositionRoot() {
        AppFrameworkAssembly().assemble(container: container)
        CoordinatorAssembly().assemble(container: container)
        WebBrowserAssembly().assemble(container: container)
        HTMLInspectorAssembly().assemble(container: container)
        CookieListAssembly().assemble(container: container)
        LogListAssembly().assemble(container: container)
    }
}
