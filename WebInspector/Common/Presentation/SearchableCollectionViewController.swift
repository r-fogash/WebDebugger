//
//  SearchableCollectionViewController.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import UIKit

class SearchableCollectionViewController: UIViewController,
                                            UISearchControllerDelegate,
                                            UISearchResultsUpdating,
                                            UISearchBarDelegate
{
    var collectionView: UICollectionView!
    var searchResultFrameLayer: CALayer!
    var textFormatter: TextFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installCollectionView()
        setupSearchResultFrameLayer()
    }
    
    func installCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewLayout()
    }
    
    func setupSearchController(searchOptionsViewModel: SearchOptionsViewModel) {
        let searchController = UISearchController(searchResultsController: nil)
        let searchOptionsView = Bundle.main.loadNibNamed("SearchOptionsView", owner: self, options: [.externalObjects:[ "searchOptionsViewModel" : searchOptionsViewModel ]])!.first as! SearchOptionsView
        searchOptionsView.translatesAutoresizingMaskIntoConstraints = false
        
        searchController.view.addSubview(searchOptionsView)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchOptionsView.topAnchor.constraint(equalTo: searchController.view.safeAreaLayoutGuide.topAnchor),
            searchOptionsView.leftAnchor.constraint(equalTo: searchController.view.leftAnchor),
            searchOptionsView.trailingAnchor.constraint(equalTo: searchController.view.trailingAnchor)
        ])
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupSearchResultFrameLayer() {
        searchResultFrameLayer = CALayer()
        searchResultFrameLayer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor
        searchResultFrameLayer.borderWidth = 2
        searchResultFrameLayer.borderColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        searchResultFrameLayer.cornerRadius = 5
    }
    
    func scrollTo(indexPath: IndexPath, textRange: Range<String.Index>, fieldName: String?, animated: Bool) {
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            finishScrollTo(indexPath: indexPath, textRange: textRange, fieldName: fieldName, animated: true)
            return
        }
        
        let animationDuration = 0.35
        
        UIView.animate(withDuration: animationDuration / 2, delay: 0, options: [.curveEaseIn]) {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        } completion: { completed in
            UIView.animate(withDuration: animationDuration / 2, delay: 0, options: [.curveEaseOut]) {
                self.finishScrollTo(indexPath: indexPath, textRange: textRange, fieldName: fieldName, animated: true)
            }
        }
    }
    
    func finishScrollTo(indexPath: IndexPath, textRange: Range<String.Index>, fieldName: String?, animated: Bool) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TextFrameAbleCollectionViewCell else {
            return
        }
        var rect = cell.rectOfText(range: textRange, field: fieldName)
        var layerRect = rect
            
        layerRect.origin.y = ceil(layerRect.origin.y - 5)
        layerRect.origin.x = ceil(layerRect.origin.x - 5)
        layerRect.size.width = ceil(layerRect.size.width + 10)
        layerRect.size.height = ceil(layerRect.size.height + 10)
            
        rect = self.collectionView.convert(rect, from: cell.contentView)
            
        rect.size.height = max(40, rect.size.height)
        self.collectionView.scrollRectToVisible(rect, animated: animated)
            
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.searchResultFrameLayer.removeFromSuperlayer()
        cell.contentView.layer.addSublayer(self.searchResultFrameLayer)
        self.searchResultFrameLayer.frame = layerRect
        
        CATransaction.commit()
    }
    
    // MARK: UISearchControllerDelegate
    
    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.35, delay: 0, options: []) {
            self.additionalSafeAreaInsets.top = 50
        } completion: { _ in }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.35, delay: 0, options: []) {
            self.additionalSafeAreaInsets.top = 0
        } completion: { _ in }
        
        if let searchResultFrameLayer {
            searchResultFrameLayer.removeFromSuperlayer()
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
