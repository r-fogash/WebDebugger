//
//  TextSearcher.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import Foundation

protocol TextSearcher {
    func execute(string: String, in text: String, caseOption: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions) -> [Range<String.Index>]
}
