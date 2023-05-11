//
//  DefaultURLStringRefiner.swift
//  WebInspector
//
//  Created by Robert on 25.05.2022.
//

import Foundation

class DefaultURLStringRefiner: URLStringRefiner {
    
    func execute(_ urlString: String?) -> URL? {
        guard var text = urlString, !text.isEmpty else {
            return nil
        }
        
        let regExp = try! NSRegularExpression(pattern: "^\\w+:\\/\\/", options: [.caseInsensitive, .useUnicodeWordBoundaries])
        if regExp.numberOfMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) == 0 {
            text = "http://" + text
        }
        
        return URL(string: text)
    }
    
}
