//
//  LogListViewController.swift
//  WebInspector
//
//  Created by Robert on 04.07.2022.
//

import UIKit

// MARK: Models for DataSource snapshots

class ActionItem: Hashable {
    static func == (lhs: ActionItem, rhs: ActionItem) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}

class RequestActionItem: ActionItem {
    let request: URLRequest
    let isHeader: Bool
    
    init(_ request: URLRequest, isHeader: Bool) {
        self.request = request
        self.isHeader = isHeader
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(request)
        hasher.combine(isHeader)
    }
    
    static func == (lhs: RequestActionItem, rhs: RequestActionItem) -> Bool {
        lhs.request == rhs.request &&
        lhs.isHeader == rhs.isHeader
    }
}

class ResponseActionItem: ActionItem {
    let response: URLResponse
    let isHeader: Bool
    
    init(_ response: URLResponse, isHeader: Bool) {
        self.response = response
        self.isHeader = isHeader
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(response)
        hasher.combine(isHeader)
    }
    
    static func == (lhs: ResponseActionItem, rhs: ResponseActionItem) -> Bool {
        lhs.response == rhs.response &&
        lhs.isHeader == rhs.isHeader
    }
}

class RedirectActionItem: ActionItem {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

class UserActionActionItem: ActionItem {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: UserActionActionItem, rhs: UserActionActionItem) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: ViewController

class LogListViewController: UIViewController {

    enum Sections {
        case main
    }
    
    weak var collectionView: UICollectionView!
    var datasource: UICollectionViewDiffableDataSource<Sections, ActionItem>!
    var viewModel: LogsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupDataSource()
        
        navigationItem.title = viewModel.sceneTitle
    }
    
    private func setupCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout())
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.collectionView = collectionView
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
    }

    private func setupDataSource() {
        let requestCellNib = UINib(nibName: "LogRequestHeaderCollectionViewCell", bundle: nil)
        let responseCellNib = UINib(nibName: "LogsResponseCollectionViewCell", bundle: nil)
        let userActionCellNib = UINib(nibName: "LogUserActionCollectionViewCell", bundle: nil)
        let redirectActionCellNib = UINib(nibName: "LogRedirectCollectionViewCell", bundle: nil)
        let logDetailCellNib = UINib(nibName: "LogDetailsCollectionViewCell", bundle: nil)
        
        let requestCellRegistration = UICollectionView.CellRegistration<LogRequestHeaderCollectionViewCell, RequestActionItem>(cellNib: requestCellNib) { [unowned self] cell, indexPath, itemIdentifier in
            cell.domainLabel.text = itemIdentifier.request.url?.host
            self.defineExpandedState(cell: cell, at: indexPath)
        }
        let responseCellRegistration = UICollectionView.CellRegistration<LogsResponseCollectionViewCell, ResponseActionItem>(cellNib: responseCellNib) { [unowned self] cell, indexPath, itemIdentifier in
            cell.domainLabel.text = itemIdentifier.response.url?.host
            if let httpResponse = itemIdentifier.response as? HTTPURLResponse {
                cell.statusCodeLabel.text = String(httpResponse.statusCode)
            }
            self.defineExpandedState(cell: cell, at: indexPath)
        }
        let userActionCellRegistration = UICollectionView.CellRegistration<LogUserActionCollectionViewCell, UserActionActionItem>(cellNib: userActionCellNib) { cell, indexPath, itemIdentifier in
            cell.titleTextView.text = itemIdentifier.title
        }
        let redirectActionCellRegistration = UICollectionView.CellRegistration<LogRedirectCollectionViewCell, RedirectActionItem>(cellNib: redirectActionCellNib) { cell, indexPath, itemIdentifier in
            cell.urlLabel.text = itemIdentifier.url.absoluteString
        }
        let requestDetailsCellRegistration = UICollectionView.CellRegistration<LogDetailsCollectionViewCell, RequestActionItem>(cellNib: logDetailCellNib) { [unowned self] cell, indexPath, itemIdentifier in
            cell.set(request: itemIdentifier.request)
            cell.delegate = self
        }
        let responseDetailsCellRegistration = UICollectionView.CellRegistration<LogDetailsCollectionViewCell, ResponseActionItem>(cellNib: logDetailCellNib) { [unowned self] cell, indexPath, itemIdentifier in
            cell.set(response: itemIdentifier.response)
            cell.delegate = self
        }

        datasource = UICollectionViewDiffableDataSource<Sections, ActionItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            if let requestAction = itemIdentifier as? RequestActionItem {
                if requestAction.isHeader {
                    return collectionView.dequeueConfiguredReusableCell(using: requestCellRegistration, for: indexPath, item: requestAction)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: requestDetailsCellRegistration, for: indexPath, item: requestAction)
                }
            }
            else if let responseAction = itemIdentifier as? ResponseActionItem {
                if responseAction.isHeader {
                    return collectionView.dequeueConfiguredReusableCell(using: responseCellRegistration, for: indexPath, item: responseAction)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: responseDetailsCellRegistration, for: indexPath, item: responseAction)
                }
            }
            else if let redirectAction = itemIdentifier as? RedirectActionItem {
                return collectionView.dequeueConfiguredReusableCell(using: redirectActionCellRegistration, for: indexPath, item: redirectAction)
            }
            else if let userAction = itemIdentifier as? UserActionActionItem {
                return collectionView.dequeueConfiguredReusableCell(using: userActionCellRegistration, for: indexPath, item: userAction)
            }
            else {
                fatalError()
            }
        }
        
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ActionItem>()
        
        for log in viewModel.actions {
            switch log {
            case .request(let request):
                let rootItem = RequestActionItem(request, isHeader: true)
                let childItem = RequestActionItem(request, isHeader: false)
                sectionSnapshot.append([rootItem])
                sectionSnapshot.append([childItem], to: rootItem)
            case .response(let response):
                let rootItem = ResponseActionItem(response, isHeader: true)
                let childItem = ResponseActionItem(response, isHeader: false)
                sectionSnapshot.append([rootItem])
                sectionSnapshot.append([childItem], to: rootItem)
            case .userAction(let name):
                sectionSnapshot.append([UserActionActionItem(name)])
            case .redirect(let url):
                sectionSnapshot.append([RedirectActionItem(url: url)])
            }
        }
        
        datasource.apply(sectionSnapshot, to: .main)
    }
    
    private func defineExpandedState(cell: LogHeaderCollectionViewCell, at indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else {
            return
        }
        cell.isExpanded = datasource.snapshot(for: .main).isExpanded(item)
    }

}

// MARK: UICollectionViewDelegate

extension LogListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = datasource.itemIdentifier(for: indexPath) else {
            return
        }
        
        var snapshot = datasource.snapshot(for: .main)
        
        if snapshot.isExpanded(item) {
            snapshot.collapse([item])
        } else {
            snapshot.expand([item])
        }
        
        datasource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LogHeaderCollectionViewCell else {
            return
        }
        defineExpandedState(cell: cell, at: indexPath)
    }
    
}

// MARK: LogDetailsCollectionViewCellDelegate

extension LogListViewController: LogDetailsCollectionViewCellDelegate {
    
    func onHeaderInfo(header: String) {
        viewModel.showInfo(for: header)
    }
    
}
