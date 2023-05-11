//
//  DefaultTextFormatter.swift
//  WebInspector
//
//  Created by Robert on 26.05.2022.
//

import Foundation
import UIKit

class DefaultTextFormatter: TextFormatter {
    
    let defaultAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 11),
        .foregroundColor: UIColor(named: "regularTextColor")!
    ]
    let highlightAttributes: [NSAttributedString.Key: Any] = [
        .font : UIFont.systemFont(ofSize: 11),
        .foregroundColor : UIColor.red,
        .backgroundColor : UIColor.yellow
    ]
    let attributeKeyAttributes: [NSAttributedString.Key: Any] = [
        .font : UIFont.systemFont(ofSize: 11),
        .foregroundColor : UIColor(named: "attributeKeyColor")!
    ]
    let attributeValueAttributes: [NSAttributedString.Key: Any] = [
        .font : UIFont.systemFont(ofSize: 11),
        .foregroundColor : UIColor(named: "attributeValueColor")!
    ]
    
    func execute(highlightedRanges: [Range<String.Index>], in text: String, htmlAttributes: [String : String]) -> NSAttributedString {
        var attributedString = AttributedString(text, attributes: AttributeContainer(defaultAttributes))
        
        // highlight attributes
        for attributeKey in htmlAttributes.keys {
            guard let value = htmlAttributes[attributeKey] else {
                continue
            }
            
            guard let keyRange = attributedString.range(of: attributeKey, options: [], locale: .current) else {
                continue
            }
            
            let subs = attributedString[keyRange.upperBound..<attributedString.endIndex]
            guard let valueRange = subs.range(of: value, options: [], locale: .current) else {
                continue
            }
            
            attributedString[keyRange].mergeAttributes(AttributeContainer(attributeKeyAttributes))
            attributedString[valueRange].mergeAttributes(AttributeContainer(attributeValueAttributes))
        }
        
        for range in highlightedRanges {
            let lbDistance = text.distance(from: text.startIndex, to: range.lowerBound)
            let ubDistance = text.distance(from: text.startIndex, to: range.upperBound)
            
            let lbIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: lbDistance)
            let ubIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: ubDistance)
              
            attributedString[lbIndex..<ubIndex].mergeAttributes(AttributeContainer(highlightAttributes))
        }
        
        return NSAttributedString(attributedString)
    }
}
