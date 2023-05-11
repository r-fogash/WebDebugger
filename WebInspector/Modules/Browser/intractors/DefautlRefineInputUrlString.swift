//
//  DefaultRefineInputUrlString.swift
//  MegaWebApp
//
//  Created by Robert on 25.05.2022.
//

import Foundation

protocol RefineInputUrlString {
    func start(urlString: String?) -> URL?
}

class DefaultRefineInputUrlString: RefineInputUrlString {
    
    private let coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func start(urlString: String?) -> URL? {
        guard var text = urlString, !text.isEmpty else {
            return nil
        }
        
        let regExp = try! NSRegularExpression(pattern: "^\\w+:\\/\\/", options: [.caseInsensitive, .useUnicodeWordBoundaries])
        if regExp.numberOfMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) == 0 {
            text = "http://" + text
        }
        
        guard let url = URL(string: text) else {
            coordinator.showError(message: "\(text) is not a valid URL")
            return nil
        }
        
        return url
    }
    
}
