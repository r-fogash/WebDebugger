//
//  BrowserViewController.swift
//  WebInspector
//
//  Created by Robert on 24.05.2022.
//

import UIKit
import WebKit
import Combine

protocol WebView: AnyObject {
    func evaluate(js: String, completion: @escaping (Any?, Error?)->Void)
    func load(url: URL)
}

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var info: UIBarButtonItem!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var webBackButton: UIBarButtonItem!
    @IBOutlet weak var webForwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    var webView: WKWebView!
    
    var webLogger: WebActionsLogger!
    var viewModel: BrowserViewModel!
    var datastore: WKWebsiteDataStore!
    
    private var bag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        installWebView()
        configureToolbar()
        
        viewModel.loadUrl.sink { [unowned self] url in
            webView.load(URLRequest(url: url))
        }.store(in: &bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.setToolbarHidden(false, animated: false)
        
        adjustAddressTextFieldWidth()
    }
    
    @IBAction func onInfo(_ sender: UIBarItem) {
        viewModel.onInfo()
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        webLogger.log(.userAction("navigateBack"))
        webView.goBack()
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        webLogger.log(.userAction("navigationForward"))
        webView.goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        webLogger.log(.userAction("reload"))
        viewModel.onReload()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        switch keyPath {
        case #keyPath(WKWebView.url):
            let url = change?[.newKey] as? URL
            addressTextField.text = url?.absoluteString ?? ""
        case #keyPath(WKWebView.canGoBack):
            let enabled = (change?[.newKey] as? Bool) ?? false
            webBackButton.isEnabled = enabled
        case #keyPath(WKWebView.canGoForward):
            let enabled = (change?[.newKey] as? Bool) ?? false
            webForwardButton.isEnabled = enabled
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    private func installWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = datastore
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        webView.scrollView.contentInsetAdjustmentBehavior = .always
    }
    
    private func setupNavigationItem() {
        navigationItem.backButtonTitle = ""
    }
    
    private func configureToolbar() {
        navigationController?.toolbar.backgroundColor = .systemBlue
        navigationController?.toolbar.barTintColor = .systemBlue
    }
    
    private func adjustAddressTextFieldWidth() {
        var frame = addressTextField.frame
        frame.size.width = view.frame.width - 40
        addressTextField.frame = frame
    }

}

// MARK: WebView

extension BrowserViewController: WebView {
    
    func evaluate(js: String, completion: @escaping (Any?, Error?) -> Void) {
        webView.evaluateJavaScript(js, completionHandler: completion)
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}

// MARK: UITextFieldDelegate

extension BrowserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.loadUrlString(textField.text)
        return true
    }
    
}

// MARK: WKNavigationDelegate

extension BrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        info.isEnabled = false
        reloadButton.isEnabled = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        info.isEnabled = true
    }
        
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        webLogger.log(.request(navigationAction.request))
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        webLogger.log(.redirect(webView.url!))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        webLogger.log(.response(navigationResponse.response))
        decisionHandler(.allow)
    }
}

