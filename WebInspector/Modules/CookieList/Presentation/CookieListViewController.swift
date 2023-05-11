//
//  CookieListViewController.swift
//  WebInspector
//
//  Created by Robert on 29.06.2022.
//

import UIKit
import Foundation
import Combine

class CookieListViewController: SearchableCollectionViewController {
    
    enum Section {
        case main
    }
    
    private var datastore: UICollectionViewDiffableDataSource<Section, CookieItemModel>!
    private unowned var suggestionsViewController: CookieSearchSuggestionsViewController!
    private var bag = Set<AnyCancellable>()
    
    var viewModel: CookieListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: -10)
        collectionView.delegate = self
        
        prepareDataStore()
        setupSearchController(searchOptionsViewModel: viewModel.searchOptionsViewModel)
        setupSuggestionsViewController()
        
        navigationItem.title = viewModel.sceneTitle
        
        viewModel.onViewDidLoad()
        viewModel.$dataSnapshot
            .sink { [unowned self] sectionSnapshot in
                self.datastore.apply(sectionSnapshot, to: .main, animatingDifferences: true, completion: nil)
            }
            .store(in: &bag)
        
        viewModel.$showsSuggestions
            .sink { [unowned self] showSuggestions in
                showSuggestions ? self.showSearchSuggestions() : self.hideSearchSuggestions()
            }
            .store(in: &bag)
        
        viewModel.$nextFoundItem
            .compactMap { $0 }
            .sink { [unowned self] foundItemTuple in
                let cookie = foundItemTuple.cookie
                let field = foundItemTuple.fieldName
                let range = foundItemTuple.ranges
                
                guard let cookieItemIdentifier = self.datastore.snapshot(for: .main).items.first(where: {
                    $0.cookie == cookie && $0.isHeader == false
                }) else {
                    return
                }
                
                guard let indexPath = self.datastore.indexPath(for: cookieItemIdentifier) else {
                    return
                }
                
                scrollTo(indexPath: indexPath, textRange: range, fieldName: field, animated: true)
            }
            .store(in: &bag)
    }
    
    private func setupSuggestionsViewController() {
        let suggestions = CookieSearchSuggestionsViewController()
        suggestions.delegate = self
        addChild(suggestions)
        suggestionsViewController = suggestions
    }

    override func makeCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
    }
    
    private func prepareDataStore() {
        let headerCellNib = UINib(nibName: "CookieTitleCollectionViewCell", bundle: nil)
        let detailsCellNib = UINib(nibName: "CookieDetailsCollectionViewCell", bundle: nil)
        
        typealias HeaderCellRegistration = UICollectionView.CellRegistration
            <CookieTitleCollectionViewCell, CookieItemModel>
        typealias DetailsCellRegistration = UICollectionView.CellRegistration
            <CookieDetailsCollectionViewCell, CookieItemModel>
        
        let headerCellRegistration = HeaderCellRegistration(cellNib: headerCellNib) { [unowned self] cell, indexPath, cookieItem in
            let attributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor(named: "regularTextColor")!
            ]
            cell.titleTextView.attributedText = NSMutableAttributedString(string: cookieItem.cookie.name, attributes: attributes)
            cell.titleTextView.isUserInteractionEnabled = false
            cell.isExpanded = datastore.snapshot(for: .main).isExpanded(cookieItem)
        }
        
        let detailsCellRegistration = DetailsCellRegistration(cellNib: detailsCellNib) { [unowned self] cell, indexPath, itemIdentifier in
            cell.set(cookie: itemIdentifier.cookie, highlightInfo: itemIdentifier.searchResults, textFormatter: textFormatter)
        }
        
        datastore = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if itemIdentifier.isHeader {
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: itemIdentifier)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: detailsCellRegistration, for: indexPath, item: itemIdentifier)
            }
        })
    }
    
// MARK: UISearchControllerDelegate
    
    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.onBeginSearch()
    }
    
    override func willDismissSearchController(_ searchController: UISearchController) {
        super.willDismissSearchController(searchController)
        
        viewModel.onEndSearch()
    }
    
// MARK: UISearchResultsUpdating
    
    override func updateSearchResults(for searchController: UISearchController) {
        super.updateSearchResults(for: searchController)
        
        let text = searchController.searchBar.text
        let token = searchController.searchBar.searchTextField.tokens.first?.representedObject as? HTTPCookiePropertyKey
        
        viewModel.onSearchCriteriaDidChange(text: text, token: token)
    }
}

// MARK: UICollectionViewDelegate

extension CookieListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = datastore.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.onTouch(item: item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CookieTitleCollectionViewCell {
            cell.isExpanded = viewModel.dataSnapshot.isExpanded(item)
        }
    }
    
}

extension CookieListViewController {
    
    private func showSearchSuggestions() {
        guard suggestionsViewController.view.superview != self.view else {
            return
        }
        suggestionsViewController.view.frame = view.bounds
        suggestionsViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(suggestionsViewController.view)
    }
    
    private func hideSearchSuggestions() {
        suggestionsViewController.view.removeFromSuperview()
    }
    
}

// MARK: CookieSearchSuggestionsViewControllerDelegate

extension CookieListViewController: CookieSearchSuggestionsViewControllerDelegate {
    
    func didSelect(suggestion: HTTPCookiePropertyKey) {
        let token = UISearchToken(icon: nil, text: suggestion.rawValue)
        token.representedObject = suggestion
        navigationItem.searchController?.searchBar.searchTextField.insertToken(token, at: 0)
    }
    
}
