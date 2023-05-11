//
//  DefaultWebActionsLogger.swift
//  WebInspector
//
//  Created by Robert on 04.07.2022.
//

import Foundation

class DefaultWebActionsLogger: WebActionsLogger {
    
    private(set) var logs: [LoggerAction] = []
    
    func log(_ action: LoggerAction) {
        logs.append(action)
    }
    
}
