//
//  SearchView.swift
//  WebInspector
//
//  Created by Robert on 23.06.2022.
//

import UIKit
import Combine

class SearchOptionsView: UIView {
    private var cancelableBag = Set<AnyCancellable>()
    
    @IBOutlet weak var caseOptionsButton: UIButton!
    @IBOutlet weak var wrappingOptionsButton: UIButton!
    @IBOutlet var viewModel: DefaultSearchOptionsViewModel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var searchSummaryLabel: UILabel!

    override func awakeFromNib() {
        initializeView()
    }
    
    private func initializeView() {
        configureCaseOptionsButton()
        configureWordWrapSearchOptionButton()
        
        viewModel.$canGoBackward
            .assign(to: \.isEnabled, on: backwardButton)
            .store(in: &cancelableBag)
        
        viewModel.$canGoForward
            .assign(to: \.isEnabled, on: forwardButton)
            .store(in: &cancelableBag)
        
        viewModel.$searchResultsDescription
            .map{ Optional($0) }
            .assign(to: \.text, on: searchSummaryLabel)
            .store(in: &cancelableBag)
    }
    
    func configureCaseOptionsButton() {
        caseOptionsButton.menu = makeSearchCaseOptionsMenu()
        
        viewModel.$caseOption
            .sink { [weak caseOptionsButton] option in
                var title = AttributedString(option.title())
                title.font = UIFont.systemFont(ofSize: 14)
                caseOptionsButton?.configuration?.attributedTitle = title
            }
            .store(in: &cancelableBag)
    }
    
    func configureWordWrapSearchOptionButton() {
        wrappingOptionsButton.menu = makeSearchWordWrapOptionsMenu()
        
        viewModel.$wrapOption
            .sink { [weak wrappingOptionsButton] option in
                var title = AttributedString(option.title())
                title.font = UIFont.systemFont(ofSize: 14)
                wrappingOptionsButton?.configuration?.attributedTitle = title
            }
            .store(in: &cancelableBag)
    }
    
    private func makeSearchCaseOptionsMenu() -> UIMenu {
        let actions = SearchCaseSensitivityOptions.allCases.map { option in
            UIAction(title: option.title(),
                     image: nil,
                     identifier: option.actionIdentifier(),
                     discoverabilityTitle: nil,
                     attributes: [],
                     state: viewModel.caseOption == option ? .on : .off)
            {
                [weak self] action in self?.viewModel.caseOption = option
            }
        }
        return UIMenu(title: "Case options", image: nil, identifier: nil, options: [.singleSelection], children: actions)
    }
    
    private func makeSearchWordWrapOptionsMenu() -> UIMenu {
        let actions = SearchWordWrappingOptions.allCases.map { option in
            UIAction(title: option.title(),
                     image: nil,
                     identifier: option.actionIdentifier(),
                     discoverabilityTitle: nil,
                     attributes: [],
                     state: viewModel.wrapOption == option ? .on : .off)
            {
                [weak self] action in self?.viewModel.wrapOption = option
            }
        }
        return UIMenu(title: "Wrap options", image: nil, identifier: nil, options: [.singleSelection], children: actions)
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        viewModel.nextFoundItem()
    }
    
    @IBAction func onPrevious(_ sender: UIButton) {
        viewModel.previousFoundItem()
    }
}

// MARK: UISearchBarDelegate

extension SearchOptionsView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension SearchCaseSensitivityOptions {
    
    func title() -> String {
        switch self {
        case .caseSensitive:
            return "Case sensitive"
        case .caseInsensitive:
            return "Ignore case"
        }
    }
    
    func actionIdentifier() -> UIAction.Identifier {
        switch self {
        case .caseInsensitive:
            return UIAction.Identifier("case_insensitive")
        case .caseSensitive:
            return UIAction.Identifier("case_sensitive")
        }
    }
}

extension SearchWordWrappingOptions {
    
    func title() -> String {
        switch self {
        case .contain:
            return "Contains"
        case .matchWord:
            return "Match word"
        }
    }
    
    func actionIdentifier() -> UIAction.Identifier {
        switch self {
        case .matchWord:
            return UIAction.Identifier("match_word")
        case .contain:
            return UIAction.Identifier("contains")
        }
    }
    
}

