//
//  AppFrameworkAssembly.swift
//  WebInspector
//
//  Created by Robert on 26.06.2022.
//

import UIKit
import Swinject

class AppFrameworkAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(LaunchAppInteractor.self) { r in
            LaunchAppInteractor(coordinator: r.resolve(Coordinator.self)!)
        }
        .inObjectScope(.transient)
    }
    
}
