//
//  HTMLNodesSearcher.swift
//  WebInspector
//
//  Created by Robert on 26.05.2022.
//

import Foundation

class SearchResults<T> where T: Equatable {
    
    struct Item: Equatable {
        let item: T
        let key: String
        let ranges: [Range<String.Index>]
        
        init(item: T, ranges: [Range<String.Index>]) {
            self.item = item
            self.key = ""
            self.ranges = ranges
        }
        
        init(item: T, key: String, ranges: [Range<String.Index>]) {
            self.item = item
            self.key = key
            self.ranges = ranges
        }
    }
    
    let items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
}

class HTMLNodesSearcher {
    
    private let textSearcher: TextSearcher
    
    init(textSearcher: TextSearcher) {
        self.textSearcher = textSearcher
    }
    
    func execute(text: String, in node: HTMLNode, caseOption: SearchCaseSensitivityOptions, wrappingOptions: SearchWordWrappingOptions) -> SearchResults<HTMLNode> {
        var results = SearchResults<HTMLNode>(items: [])
        
        let ranges = textSearcher.execute(string: text, in: node.text, caseOption: caseOption, wrappingOptions: wrappingOptions)
        
        if ranges.count > 0 {
            results = SearchResults(items: [.init(item: node, ranges: ranges)])
        }
        
        return node.child.reduce(results, { partialResult, node in
            partialResult.appending(results: execute(text: text, in: node, caseOption: caseOption, wrappingOptions: wrappingOptions))
        })
    }

}

extension SearchResults {
    func appending(results: SearchResults<T>) -> SearchResults<T> {
        SearchResults(items: items + results.items)
    }
}
