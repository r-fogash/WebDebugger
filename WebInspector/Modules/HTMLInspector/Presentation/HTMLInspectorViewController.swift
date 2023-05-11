//
//  HTMLInspectorViewController.swift
//  WebInspector
//
//  Created by Robert on 24.05.2022.
//

import UIKit
import Combine

// TODO: while expanding nodes ignore next button tap

class HTMLInspectorViewController: SearchableCollectionViewController {

    enum Section {
        case main
    }
    
    private var datasource: UICollectionViewDiffableDataSource<Section, HTMLNode>!
    private var cancelableBag = Set<AnyCancellable>()
    
    var viewModel: HTMLInspectorViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController(searchOptionsViewModel: viewModel.searchOptionsViewModel)
        makeDatasource()
        populateDatasource(items: [viewModel.htmlNode])
        
        viewModel.searchOptionsDidChange
            .sink { [weak self] tuple in self?.searchOptionDidChange() }
            .store(in: &cancelableBag)
        
        viewModel.$nextFoundNode
            .compactMap { $0 }
            .sink { [unowned self] item in
                let node = item.item
                let range = item.range
                
                ensureNodeIsExpanded(node) {
                    guard let indexPath = self.datasource.indexPath(for: node) else {
                        return
                    }
                    self.scrollTo(indexPath: indexPath, textRange: range, fieldName: nil, animated: true)
                }
            }
            .store(in: &cancelableBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    @IBAction func onCookies(_ sender: UIBarButtonItem) {
        viewModel.onShowCookies()
    }
    
    @IBAction func onLogs(_ sender: UIBarButtonItem) {
        viewModel.onShowLogs()
    }
    
    private func makeDatasource() {
        let cellNib = UINib(nibName: "RichTextCollectionViewCell", bundle: nil)
        
        typealias CellConfiguration = UICollectionView.CellRegistration<RichTextCollectionViewCell, HTMLNode>
        
        let contentCellRegistration = CellConfiguration(cellNib: cellNib) { [weak self] cell, indexPath, htmlNode in
            guard let self = self else { return }
            
            let searchResultItem = self.viewModel.searchResults.items.first {
                $0.item == htmlNode
            }
            let ranges = searchResultItem?.ranges ?? []
            
            let attributedText = self.textFormatter.execute(highlightedRanges: ranges, in: htmlNode.text, htmlAttributes: htmlNode.attributes)
            
            cell.level = self.datasource.snapshot(for: .main).level(of: htmlNode)
            cell.isExpanded = self.datasource.snapshot(for: .main).isExpanded(htmlNode)
            cell.configure(attributedText: attributedText, showDisclosure: true)
            cell.delegate = self
        }
        
        let leafCellRegistration = CellConfiguration(cellNib: cellNib) { [weak self] cell, indexPath, htmlNode in
            guard let self = self else { return }
            
            let searchResultItem = self.viewModel.searchResults.items.first {
                $0.item == htmlNode
            }
            let ranges = searchResultItem?.ranges ?? []
            
            let attributedText = self.textFormatter.execute(highlightedRanges: ranges, in: htmlNode.text, htmlAttributes: htmlNode.attributes)
            
            cell.level = self.datasource.snapshot(for: .main).level(of: htmlNode)
            cell.isExpanded = self.datasource.snapshot(for: .main).isExpanded(htmlNode)
            cell.configure(attributedText: attributedText, showDisclosure: false)
        }
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cellRegistration = itemIdentifier.child.isEmpty ? leafCellRegistration : contentCellRegistration
            let cell = collectionView.dequeueConfiguredReusableCell(using:cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    override func makeCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(35))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func populateDatasource(items: [HTMLNode]) {
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<HTMLNode>()
        
        func populateDatasource(items: [HTMLNode], parent: HTMLNode?) {
            sectionSnapshot.append(items, to: parent)
            
            for item in items {
                guard item.child.count > 0 else { continue }
                populateDatasource(items: item.child, parent: item)
            }
        }
        
        populateDatasource(items: items, parent: nil)
        
        datasource.apply(sectionSnapshot, to: .main)
    }
    
    func collapseAllNodes(completion: @escaping () -> Void) {
        var sectionSnapshot = datasource.snapshot(for: .main)
        
        let expandedItems = sectionSnapshot.items.filter {sectionSnapshot.isExpanded($0)}
        sectionSnapshot.collapse(expandedItems)
        
        datasource.apply(sectionSnapshot,
                         to: .main,
                         animatingDifferences: true,
                         completion: completion)
    }
    
    func performSearch(text: String?) {
        guard let searchText = text, searchText.count > 0 else {
            viewModel.searchResults = .init(items: [])
            collectionView.reloadData()
            return
        }
        
        viewModel.search(text: searchText)
        expandFoundNodes()
    }
    
    private func expandFoundNodes() {
        let foundNodes = viewModel.searchResults.items.map { item -> HTMLNode in item.item }
        expand(nodes: foundNodes)
    }
    
    private func expand(nodes: [HTMLNode]) {
        var sectionSnapshot = datasource.snapshot(for: .main)
        var parentNodesCache = [HTMLNode : HTMLNode]()
        
        func parentNode(of node: HTMLNode) -> HTMLNode? {
            if let parent = parentNodesCache[node] {
                return parent
            }
            if let parent = sectionSnapshot.parent(of: node) {
                parentNodesCache[node] = parent
                return parent
            }
            return nil
        }
        
        for node in nodes {
            var parent = parentNode(of: node)

            while (parent != nil) {
                guard !sectionSnapshot.isExpanded(parent!) else {
                    break
                }
                sectionSnapshot.expand([parent!])
                parent = parentNode(of: parent!)
            }
        }
        
        datasource.apply(sectionSnapshot, to: .main)
        collectionView.reloadData()
    }
    
    func ensureNodeIsExpanded(_ node: HTMLNode, completion: @escaping () -> Void) {
        var snapshot = datasource.snapshot(for: .main)
        var nodesToExpand = [HTMLNode]()
        
        var parentNode = snapshot.parent(of: node)
        
        while let n = parentNode {
            if !snapshot.isExpanded(n) { nodesToExpand.append(n) }
            parentNode = snapshot.parent(of: n)
        }
        
        guard !nodesToExpand.isEmpty else {
            completion()
            return
        }
        
        snapshot.expand(nodesToExpand)
        datasource.apply(snapshot, to: .main, animatingDifferences: true) {
            completion()
        }
    }
    
    func searchOptionDidChange() {
        collapseAllNodes() {
            self.performSearch(text: self.navigationItem.searchController?.searchBar.text ?? "")
        }
    }
    
    private func toggleExpandItem(at indexPath: IndexPath) -> Bool {
        var snapshot = datasource.snapshot(for: .main)
        let node = datasource.itemIdentifier(for: indexPath)!
        
        snapshot.isExpanded(node) ? snapshot.collapse([node]) : snapshot.expand([node])
        datasource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
        
        return snapshot.isExpanded(node)
    }
    
// MARK: UISearchControllerDelegate
    
    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.onPresentSearchController()
    }
    
    override func willDismissSearchController(_ searchController: UISearchController) {
        super.willDismissSearchController(searchController)
        
        viewModel.onHideSearchController()
    }
    
// MARK: UISearchResultsUpdating

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(text: searchBar.text)
    }

}

// MARK: RichTextCollectionViewCellDelegate

extension HTMLInspectorViewController: RichTextCollectionViewCellDelegate {
    
    func onDisclosure(cell: ExpandableCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        cell.isExpanded = toggleExpandItem(at: indexPath)
    }
    
}
