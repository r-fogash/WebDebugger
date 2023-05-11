//
//  CookieListViewModel.swift
//  WebInspector
//
//  Created by Robert on 01.07.2022.
//

import Foundation
import UIKit
import Combine

class CookieListViewModel {
    
    enum Mode {
        case cookieList
        case searchMode
    }
    
    private var bag = Set<AnyCancellable>()
    private let cookiesFetcher: CookiesFetcher
    private let cookiesSearcher: CookiesSearcher
    private let searchResultsCalculator: SearchResultsCalculator<Cookie>
    private var originalSnapshot: NSDiffableDataSourceSectionSnapshot<CookieItemModel>!
    private var currentSearchText: String?
    private var currentSearchToken: HTTPCookiePropertyKey?
    
    var mode: Mode = .cookieList
    let searchOptionsViewModel: SearchOptionsViewModel
    var searchResult: SearchResults<Cookie> = .init(items: [])
    let sceneTitle = "Cookies"
    
    @Published var dataSnapshot = NSDiffableDataSourceSectionSnapshot<CookieItemModel>()
    @Published var showsSuggestions = false
    @Published var nextFoundItem: (cookie: Cookie, fieldName: String, ranges: Range<String.Index>)?
    
    init(searchOptionsViewModel: SearchOptionsViewModel,
         cookiesFetcher: CookiesFetcher,
         cookiesSearcher: CookiesSearcher,
         searchResultsCalculator: SearchResultsCalculator<Cookie>)
    {
        self.searchOptionsViewModel = searchOptionsViewModel
        self.cookiesFetcher = cookiesFetcher
        self.cookiesSearcher = cookiesSearcher
        self.searchResultsCalculator = searchResultsCalculator
        
        Publishers.CombineLatest(searchOptionsViewModel.$caseOption, searchOptionsViewModel.$wrapOption)
            .sink { [weak self] newCaseOption, newWordWrappingOption in
                guard let self = self else { return }
                self.onSearchCriteriaDidChange(text: self.currentSearchText,
                                               token: self.currentSearchToken,
                                               caseOption: newCaseOption,
                                               wordWrappingOption: newWordWrappingOption)
            }
            .store(in: &bag)
        
        searchOptionsViewModel.$currentFoundItemIndex
            .filter { $0 != -1 }
            .sink { [unowned self] index in
                let item = try! self.searchResultsCalculator.item(at: index, in: self.searchResult)
                self.nextFoundItem = (item.item, item.key, item.range)
            }
            .store(in: &bag)
        
        searchOptionsViewModel.$currentFoundItemIndex
            .filter{ $0 == -1 }
            .sink { [unowned self] _ in
                self.nextFoundItem = nil
            }
            .store(in: &bag)
    }
    
    func onViewDidLoad() {
        cookiesFetcher.execute { cookies in
            cookies.forEach { [weak self] cookie in
                guard let self = self else { return }
                let header = CookieItemModel(cookie: cookie, isHeader: true)
                let subitem = CookieItemModel(cookie: cookie, isHeader: false)
                
                self.dataSnapshot.append([header])
                self.dataSnapshot.append([subitem], to: header)
            }
        }
    }
    
    func onBeginSearch() {
        mode = .searchMode
        originalSnapshot = dataSnapshot
        showsSuggestions = true
        searchOptionsViewModel.isSearchToolbarVisible = true
    }
    
    func onEndSearch() {
        mode = .cookieList
        dataSnapshot = originalSnapshot
        originalSnapshot = nil
        showsSuggestions = false
        searchOptionsViewModel.isSearchToolbarVisible = false
        currentSearchText = nil
        currentSearchToken = nil
    }
    
    func didSelect(suggestion: HTTPCookiePropertyKey) {
        showsSuggestions = false
    }
    
    func didChange(searchText: String) {
        showsSuggestions = false
    }
    
    func onSearchCriteriaDidChange(text: String?, token: HTTPCookiePropertyKey?) {
        onSearchCriteriaDidChange(text: text,
                                  token: token,
                                  caseOption: searchOptionsViewModel.caseOption,
                                  wordWrappingOption: searchOptionsViewModel.wrapOption)
    }
    
    func onSearchCriteriaDidChange(text: String?,
                                   token: HTTPCookiePropertyKey?,
                                   caseOption: SearchCaseSensitivityOptions,
                                   wordWrappingOption: SearchWordWrappingOptions)
    {
        guard mode == .searchMode else {
            return
        }
        
        currentSearchText = text
        currentSearchToken = token
        
        showsSuggestions = (text == nil || text?.count == 0) && token == nil
        
        if let searchText = text {
            guard searchText.count > 0 else {
                dataSnapshot = originalSnapshot
                return
            }
            
            let cookies = originalSnapshot.rootItems.map(\.cookie)
            searchResult = cookiesSearcher.execute(with: searchText,
                                                   in: cookies,
                                                   cookieAttribute: token,
                                                   caseOption: caseOption,
                                                   wrappingOptions: wordWrappingOption)
            
            var searchSnapshot = NSDiffableDataSourceSectionSnapshot<CookieItemModel>()
            
            let cookieItemIdentifierList = searchResult.items
                .map {
                    CookieItemModel(cookie: $0.item,
                                         isHeader: false,
                                         searchResults: [$0.key : $0.ranges])
                }
                .reduce(into: [CookieItemModel]()) { partialResult, cookieItemIdentifier in
                    if var sameCookie = partialResult.filter({ $0.cookie == cookieItemIdentifier.cookie }).first {
                        partialResult.removeAll { $0.cookie == cookieItemIdentifier.cookie }
                        sameCookie.append(searchResults: cookieItemIdentifier.searchResults)
                        partialResult.append(sameCookie)
                    } else {
                        partialResult.append(cookieItemIdentifier)
                    }
                }
            
            for rr in cookieItemIdentifierList {
                let cookieItem = CookieItemModel(cookie: rr.cookie, isHeader: true)
                let cookieSubitem = CookieItemModel(cookie: rr.cookie, isHeader: false, searchResults: rr.searchResults)
                
                searchSnapshot.append([cookieItem])
                searchSnapshot.append([cookieSubitem], to: cookieItem)
            }
            searchSnapshot.expand(searchSnapshot.items.filter{searchSnapshot.level(of: $0) == 0})
            let numberOfMatches = searchResultsCalculator.numberOfMatches(in: searchResult)
            
            dataSnapshot = searchSnapshot
            searchOptionsViewModel.set(numberOfMatches: numberOfMatches)
        }
    }
    
    func onTouch(item: CookieItemModel) {
        guard dataSnapshot.rootItems.contains(item) else {
            return
        }
        if dataSnapshot.isExpanded(item) {
            dataSnapshot.collapse([item])
        } else {
            dataSnapshot.expand([item])
        }
    }
}
