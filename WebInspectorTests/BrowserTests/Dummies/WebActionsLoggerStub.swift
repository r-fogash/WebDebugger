//
//  WebActionsLoggerStub.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import Foundation
@testable import WebInspector

class WebActionsLoggerStub: WebActionsLogger {
    var logs: [LoggerAction] = []
    var loggerActions = [Action]()
    
    enum Action: Equatable {
        case logAction(_ action: LoggerAction)
    }
    
    func log(_ action: LoggerAction) {
        loggerActions.append(.logAction(action))
    }
}
