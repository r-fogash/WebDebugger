//
//  TextFormatter.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import UIKit

protocol TextFormatter {
    func execute(highlightedRanges: [Range<String.Index>], in text: String, htmlAttributes: [String : String]) -> NSAttributedString
}
