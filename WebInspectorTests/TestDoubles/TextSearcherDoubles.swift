//
//  TextSearcherSpy.swift
//  WebInspectorTests
//
//  Created by Robert on 30.06.2022.
//

import Foundation
@testable import WebInspector

class TextSearcherStub: TextSearcher {
    
    struct ResultHandler: Hashable {
        let result: [Range<String.Index>]
        let text: String
    }
    
    var resultHandlers = [ResultHandler]()
    
    func execute(string: String, in text: String, caseOption: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions) -> [Range<String.Index>] {
        if let result = resultHandlers.first(where: { $0.text == text}) {
            return result.result
        } else {
            return []
        }
    }

}

class TextSearcherSpy: TextSearcherStub {

    enum Action: Equatable {
        case search(string: String, text: String, caseOption: SearchCaseSensitivityOptions, wrappingOption: SearchWordWrappingOptions)
    }
    
    var actions = [Action]()
    
    override func execute(string: String, in text: String, caseOption: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions) -> [Range<String.Index>] {
        actions.append(.search(string: string, text: text, caseOption: caseOption, wrappingOption: wrappingOptions))
        
        return super.execute(string: string, in: text, caseOption: caseOption, wrappingOptions: wrappingOptions)
    }
    
}
