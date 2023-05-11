//
//  DefaultSearchOptionsViewModel.swift
//  WebInspector
//
//  Created by Robert on 22.06.2022.
//

import Foundation
import Combine

class DefaultSearchOptionsViewModel: SearchOptionsViewModel {
    
    private var bag = Set<AnyCancellable>()
    private var numberOfMatches: Int = -1
    
    override init() {
        super.init()
        
        $isSearchToolbarVisible
            .filter { $0 == false }
            .sink { [weak self] value in
                guard let self = self else { return }
                self.caseOption = self.defaultCaseOption
                self.wrapOption = self.defaultWrapOption
                self.searchResultsDescription = self.searchResultsDescriptionDefaultValue
                self.numberOfMatches = -1
                self.currentFoundItemIndex = self.currentFoundItemIndexDefaultValue
            }
            .store(in: &bag)
        
        $currentFoundItemIndex
            .sink { [weak self] itemIndex in
                guard let self = self else { return }
            
                if itemIndex == -1 {
                    self.canGoBackward = false
                    self.canGoForward = false
                } else {
                    self.canGoBackward = itemIndex > 0
                    self.canGoForward = self.numberOfMatches > 1 && (itemIndex < self.numberOfMatches - 1)
                }
                self.updateSearchResultsDescription(currentIndex: itemIndex)
            }
            .store(in: &bag)
    }
    
    override func set(numberOfMatches: Int) {
        self.numberOfMatches = numberOfMatches
        currentFoundItemIndex = numberOfMatches > 1 ? 0 : -1
    }
    
    override func nextFoundItem() {
        if currentFoundItemIndex < numberOfMatches - 1 {
            currentFoundItemIndex += 1
        }
    }
    
    override func previousFoundItem() {
        if currentFoundItemIndex > 0 {
            currentFoundItemIndex -= 1
        }
    }
    
    private func updateSearchResultsDescription(currentIndex: Int) {
        if currentIndex == -1 && numberOfMatches == -1 {
            searchResultsDescription = ""
        } else if numberOfMatches == 0 {
            searchResultsDescription = "No match"
        } else {
            searchResultsDescription = "\(currentIndex + 1)/\(numberOfMatches)"
        }
    }
}
