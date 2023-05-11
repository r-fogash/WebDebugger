//
//  HTMLInspectorViewModel.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import Foundation
import Combine

class HTMLInspectorViewModel {
    private weak var navigationDelegate: HTMLInspectorNavigationDelegate?
    private let searchNodes: HTMLNodesSearcher
    private let searchResultsCalculator: SearchResultsCalculator<HTMLNode>
    private var bag = Set<AnyCancellable>()
    
    public let htmlNode: HTMLNode
    public var searchResults: SearchResults<HTMLNode>
    public let searchOptionsViewModel: SearchOptionsViewModel
    public let searchOptionsDidChange: PassthroughSubject<Void, Never>
    
    @Published var nextFoundNode: SearchResultsCalculator<HTMLNode>.CalculatedItem?
    
    init(htmlNode: HTMLNode,
         searchNodes: HTMLNodesSearcher,
         searchOptionsViewModel: SearchOptionsViewModel,
         searchResultsCalculator: SearchResultsCalculator<HTMLNode>,
         navigationDelegate: HTMLInspectorNavigationDelegate? = nil)
    {
        self.htmlNode = htmlNode
        self.searchResults = .init(items: [])
        self.searchNodes = searchNodes
        self.searchOptionsViewModel = searchOptionsViewModel
        self.searchResultsCalculator = searchResultsCalculator
        self.navigationDelegate = navigationDelegate
        self.searchOptionsDidChange = .init()
        
        Publishers.CombineLatest(searchOptionsViewModel.$caseOption, searchOptionsViewModel.$wrapOption)
            .sink { [weak self] _ in self?.searchOptionsDidChange.send(()) }
            .store(in: &bag)
        
        searchOptionsViewModel.$currentFoundItemIndex
            .filter { $0 == -1 }
            .map { _ -> SearchResultsCalculator<HTMLNode>.CalculatedItem? in nil }
            .assign(to: &$nextFoundNode)
        
        searchOptionsViewModel.$currentFoundItemIndex
            .filter { $0 != -1 }
            .map { [weak self] itemIndex -> SearchResultsCalculator<HTMLNode>.CalculatedItem? in
                guard let self = self else { return nil }
                return try! self.searchResultsCalculator.item(at: itemIndex, in: self.searchResults)
            }
            .assign(to: &$nextFoundNode)
    }
    
    func onShowCookies() {
        navigationDelegate?.openCookies()
    }
    
    func onShowLogs() {
        navigationDelegate?.openLogs()
    }
    
    func search(text: String)
    {
        searchResults = searchNodes.execute(text: text,
                                           in: htmlNode,
                                           caseOption: searchOptionsViewModel.caseOption,
                                           wrappingOptions: searchOptionsViewModel.wrapOption)
        
        // Ugly hack to fix disappear of highlighted rect
        DispatchQueue.main.async {
            self.searchOptionsViewModel.set(numberOfMatches: self.searchResultsCalculator.numberOfMatches(in: self.searchResults))
        }
    }
    
    func onPresentSearchController() {
        searchOptionsViewModel.isSearchToolbarVisible = true
    }
    
    func onHideSearchController() {
        searchOptionsViewModel.isSearchToolbarVisible = false
    }
    
}
