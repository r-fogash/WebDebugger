//
//  SearchOptionsViewModel.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import Foundation
import Combine

enum SearchCaseSensitivityOptions: CaseIterable {
    case caseInsensitive
    case caseSensitive
}

enum SearchWordWrappingOptions: CaseIterable {
    case contain
    case matchWord
}

class SearchOptionsViewModel: NSObject {
    let defaultCaseOption: SearchCaseSensitivityOptions = .caseInsensitive
    let defaultWrapOption: SearchWordWrappingOptions = .contain
    let searchResultsDescriptionDefaultValue = ""
    let currentFoundItemIndexDefaultValue = -1
    
    @Published var currentFoundItemIndex: Int
    @Published var isSearchToolbarVisible: Bool
    @Published var caseOption: SearchCaseSensitivityOptions
    @Published var wrapOption: SearchWordWrappingOptions
    @Published var canGoBackward: Bool
    @Published var canGoForward: Bool
    @Published var searchResultsDescription: String
    
    override init() {
        self.currentFoundItemIndex = currentFoundItemIndexDefaultValue
        self.searchResultsDescription = searchResultsDescriptionDefaultValue
        self.isSearchToolbarVisible = false
        self.caseOption = defaultCaseOption
        self.wrapOption = defaultWrapOption
        self.canGoForward = false
        self.canGoBackward = false
        
        super.init()
    }
    
    func set(numberOfMatches: Int) { }
    func nextFoundItem() { }
    func previousFoundItem() { }
}
