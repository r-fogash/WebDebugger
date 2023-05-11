//
//  WebActionsLogger.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import Foundation

enum LoggerAction: Equatable {
    case request(_ urlRequest: URLRequest)
    case response( _ urlResponse: URLResponse)
    case userAction(_ name: String)
    case redirect(_ url: URL)
}

protocol WebActionsLogger {
    var logs: [LoggerAction] { get }
    func log(_ action: LoggerAction)
}
