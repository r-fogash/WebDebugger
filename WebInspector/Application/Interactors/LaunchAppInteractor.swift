//
//  LaunchAppInteractor.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import UIKit

class LaunchAppInteractor {
    
    let coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func execute() {
        coordinator.start()
    }
}
