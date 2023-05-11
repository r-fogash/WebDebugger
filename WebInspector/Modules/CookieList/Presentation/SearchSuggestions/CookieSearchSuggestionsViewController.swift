//
//  CookieSearchSuggestionsViewController.swift
//  WebInspector
//
//  Created by Robert on 30.06.2022.
//

import UIKit
import Foundation

protocol CookieSearchSuggestionsViewControllerDelegate: AnyObject
{
    func didSelect(suggestion: HTTPCookiePropertyKey)
}

class CookieSearchSuggestionsViewController: UIViewController {

    let suggestions = [
        HTTPCookiePropertyKey.name,
        HTTPCookiePropertyKey.value,
        HTTPCookiePropertyKey.expires,
        HTTPCookiePropertyKey.domain,
        HTTPCookiePropertyKey.path,
        HTTPCookiePropertyKey.discard,
        HTTPCookiePropertyKey.maximumAge,
        HTTPCookiePropertyKey.version,
        HTTPCookiePropertyKey.secure,
        HTTPCookiePropertyKey.comment,
        HTTPCookiePropertyKey.commentURL,
        HTTPCookiePropertyKey.originURL,
        HTTPCookiePropertyKey.port,
    ]
    
    var tableView: UITableView!
    weak var delegate: CookieSearchSuggestionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        installTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func subscribeToKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(willHideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func willShowKeyboard(_ notification: NSNotification) {
        guard let kbRectValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let kbRect = kbRectValue.cgRectValue
        
        var inset = tableView.contentInset
        inset.bottom = kbRect.height
        tableView.contentInset = inset
    }
    
    @objc private func willHideKeyboard(_ notification: NSNotification) {
        var inset = tableView.contentInset
        inset.bottom = view.safeAreaInsets.bottom
        tableView.contentInset = inset
    }
    
    private func installTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

}

// MARK: UITableViewDataSource

extension CookieSearchSuggestionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let tmpCell = tableView.dequeueReusableCell(withIdentifier: "reuse identifier") {
            cell = tmpCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuse identifier")
        }
        var configuration = cell.defaultContentConfiguration()
        configuration.text = suggestions[indexPath.row].rawValue
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else { return nil }
        return "Suggested Searches"
    }
    
}

// MARK: UITableViewDelegate

extension CookieSearchSuggestionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didSelect(suggestion: suggestions[indexPath.row])
    }
    
}
