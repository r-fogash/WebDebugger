//
//  BrowserViewModelSpy.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import Foundation
@testable import WebInspector

class BrowserViewModelSpy: BrowserViewModel {
    
    enum Action: Equatable {
        case onInfo
        case onReload
        case loadUrlString(argument: String?)
    }
    
    var actions = [Action]()
    
    override func onInfo() {
        actions.append(.onInfo)
    }
    
    override func onReload() {
        actions.append(.onReload)
    }
    
    override func loadUrlString(_ urlString: String?) {
        actions.append(.loadUrlString(argument: urlString))
    }
}
