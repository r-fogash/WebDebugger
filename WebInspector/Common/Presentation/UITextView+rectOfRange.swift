//
//  UITextView+frameOfRange.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import UIKit

extension UITextView {
    
    func rect(of range: Range<String.Index>) -> CGRect {
        guard let attributedText else {
            return .zero
        }
        let location = attributedText.string.distance(from: attributedText.string.startIndex, to: range.lowerBound)
        let length = attributedText.string[range].unicodeScalars.count
        let nsRange = NSRange(location: location, length: length)
        
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: nsRange, actualGlyphRange: &glyphRange)
        
        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        rect.origin.y += textContainerInset.top
        rect.origin.x += textContainerInset.left
        
        return rect
    }
    
}
