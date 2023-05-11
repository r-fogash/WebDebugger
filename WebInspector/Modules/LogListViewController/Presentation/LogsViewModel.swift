//
//  LogsViewModel.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import Foundation

class LogsViewModel {
    private let headerDescriptionOpener: HeaderDescriptionOpener
    private let logger: WebActionsLogger
    
    let sceneTitle = "Web action logs"
    var actions: [LoggerAction] {
        logger.logs
    }
    
    init(headerDescriptionOpener: HeaderDescriptionOpener, logger: WebActionsLogger) {
        self.headerDescriptionOpener = headerDescriptionOpener
        self.logger = logger
    }
    
    func showInfo(for header: String) {
        headerDescriptionOpener.execute(header)
    }
}
