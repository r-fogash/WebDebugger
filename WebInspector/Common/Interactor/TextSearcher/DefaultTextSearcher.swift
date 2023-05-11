//
//  DefaultTextSearcher.swift
//  WebInspector
//
//  Created by Robert on 30.06.2022.
//

import Foundation

class DefaultTextSearcher: TextSearcher {
    
    private let wordContainsStrategy: TextSearcherWrappingStrategy
    private let wordMatchStrategy: TextSearcherWrappingStrategy
    
    init(wordContainsStrategy: TextSearcherWrappingStrategy, wordMatchStrategy: TextSearcherWrappingStrategy) {
        self.wordContainsStrategy = wordContainsStrategy
        self.wordMatchStrategy = wordMatchStrategy
    }
    
    func execute(string: String, in text: String, caseOption: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions) -> [Range<String.Index>] {
        let searchStrategy = strategy(for: wrappingOptions)
        return searchStrategy.search(string: string, in: text, caseOption: caseOption)
    }
    
    private func strategy(for option: SearchWordWrappingOptions) -> TextSearcherWrappingStrategy {
        switch option {
        case .contain:
            return wordContainsStrategy
        case .matchWord:
            return wordMatchStrategy
        }
    }
}

// MARK: protocol TextSearcherWrappingStrategy

protocol TextSearcherWrappingStrategy {
    func search(string: String, in text: String, caseOption: SearchCaseSensitivityOptions) -> [Range<String.Index>]
}

// MARK: TextSearcherContainsStrategy

class TextSearcherContainsStrategy: TextSearcherWrappingStrategy {
    
    func search(string: String, in text: String, caseOption: SearchCaseSensitivityOptions) -> [Range<String.Index>] {
        let options: NSString.CompareOptions = (caseOption == .caseInsensitive) ? .caseInsensitive : []
        
        var searchRange = text.startIndex..<text.endIndex
        var foundRangeList: [Range<String.Index>] = []
        
        repeat {
            guard let r = text.range(of: string, options: options, range: searchRange, locale: .current) else {
                break
            }
            foundRangeList.append(r)
            searchRange = r.upperBound..<text.endIndex
        }
        while true

        return foundRangeList
    }
    
}

// MARK: TextSearcherWrappingStrategy

class TextSearchMatchWordStrategy: TextSearcherWrappingStrategy {
    
    func search(string: String, in text: String, caseOption: SearchCaseSensitivityOptions) -> [Range<String.Index>] {
        let options: NSString.CompareOptions = (caseOption == .caseInsensitive) ? .caseInsensitive : []
        
        var foundRangeList: [Range<String.Index>] = []
        var searchRange = text.startIndex..<text.endIndex
        let alphanumeric = NSCharacterSet.alphanumerics
        
        repeat {
            guard let r = text.range(of: string, options: options, range: searchRange, locale: .current) else {
                break
            }
            var startOK = true
            var endOK = true
            
            if r.lowerBound != text.startIndex {
                let prevIndex = text.index(before: r.lowerBound)
                let unicodeScalar = text.unicodeScalars[prevIndex]
                
                if alphanumeric.contains(unicodeScalar) {
                    startOK = false
                }
            }
            if r.upperBound != text.endIndex {
                let nextIndex = r.upperBound
                let unicodeScalar = text.unicodeScalars[nextIndex]
                
                if alphanumeric.contains(unicodeScalar) {
                    endOK = false
                }
            }
            if startOK && endOK {
                foundRangeList.append(r)
            }
            searchRange = r.upperBound..<text.endIndex
        }
        while true

        return foundRangeList
    }
    
}
