//
//  SearchResultsCalculator.swift
//  WebInspector
//
//  Created by Robert on 27.06.2022.
//

import Foundation

extension SearchResults: Equatable {
    static func == (lhs: SearchResults<T>, rhs: SearchResults<T>) -> Bool {
        lhs.items == rhs.items
    }
}

class SearchResultsCalculator<T> where T: Equatable {
    
    struct CalculatedItem : Equatable {
        let item: T
        let key: String
        let range: Range<String.Index>
    }
    
    enum Errors: Error {
        case searchResultItemOutOfBounds
    }
    
    func numberOfMatches(in results: SearchResults<T>) -> Int {
        results.items.reduce(0) { partialResult, item in
            partialResult + item.ranges.count
        }
    }
    
    func item(at index: Int, in searchResults: SearchResults<T>) throws -> CalculatedItem {
        var foundItem: T?
        var foundRange: Range<String.Index>?
        var foundKey: String?
        
        var progress = 0

        for item in searchResults.items {
            let indexInRanges = index - progress
            
            if indexInRanges >= item.ranges.count {
                progress += item.ranges.count
                continue
            }
            foundItem = item.item
            foundRange = item.ranges[indexInRanges]
            foundKey = item.key
            break
        }

        guard let item = foundItem, let range = foundRange else {
            throw Errors.searchResultItemOutOfBounds
        }

        return .init(item: item, key: foundKey!,  range: range)
    }

}
