//
//  LogDetailsCollectionViewCell.swift
//  WebInspectorApp
//
//  Created by Robert on 04.07.2022.
//

import UIKit

protocol LogDetailsCollectionViewCellDelegate: AnyObject
{
    func onHeaderInfo(header: String)
}

class LogDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: LogDetailsCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func set(request: URLRequest) {
        addSectionHeader(title: "Request info")
        
        if let method = request.httpMethod {
            stackView.addArrangedSubview(makeDetailItemView(key: "Method", value: method))
        }
        if let host = request.url?.host {
            stackView.addArrangedSubview(makeDetailItemView(key: "Host", value: host))
        }
        if let path = request.url?.path {
            stackView.addArrangedSubview(makeDetailItemView(key: "Path", value: path))
        }
        if let port = request.url?.port {
            stackView.addArrangedSubview(makeDetailItemView(key: "Port", value: String(port)))
        }
        if let fragment = request.url?.fragment {
            stackView.addArrangedSubview(makeDetailItemView(key: "Fragment", value: fragment))
        }
        if let user = request.url?.user {
            stackView.addArrangedSubview(makeDetailItemView(key: "User", value: user))
        }
        if let password = request.url?.password {
            stackView.addArrangedSubview(makeDetailItemView(key: "Password", value: password))
        }
        
        addQueryItems(request: request)
        
        addSectionHeader(title: "Headers")
        fillHeadersInfo(request.allHTTPHeaderFields ?? [:])
    }
    
    private func addQueryItems(request: URLRequest) {
        guard let url = request.url else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              !queryItems.isEmpty
        else { return }
        
        addSectionHeader(title: "Query items")
        for queryItem in queryItems {
            stackView.addArrangedSubview(makeDetailItemView(key: queryItem.name, value: queryItem.value ?? ""))
        }
    }
    
    func set(response: URLResponse) {
        addSectionHeader(title: "Response Info")
        
        if let httpResponse = response as? HTTPURLResponse {
            stackView.addArrangedSubview(makeDetailItemView(key: "Status code", value: String(httpResponse.statusCode)))
            
            addSectionHeader(title: "Headers")
            
            let mappedHeaders = httpResponse.allHeaderFields
                .map { ($0.key.description, "\($0.value)") }
                .reduce(into: [:]) { (partialResult, dictionaryRecord: (key: String, value: String)) in
                    partialResult[dictionaryRecord.key] = dictionaryRecord.value
                }
            fillHeadersInfo(mappedHeaders)
        } else {
            let detailView = makeDetailItemView(key: "URL", value: response.url?.absoluteString ?? "")
            detailView.infoButton.isHidden = false
            detailView.delegate = self
            stackView.addArrangedSubview(detailView)
        }
    }
    
    private func fillHeadersInfo(_ headers: [String : String]) {
        for (key, value) in headers {
            let detailView = makeDetailItemView(key: key, value: value)
            detailView.infoButton.isHidden = false
            detailView.delegate = self
            stackView.addArrangedSubview(detailView)
        }
    }
    
    private func addSectionHeader(title: String) {
        stackView.addArrangedSubview(makeTitleLabel(text: title))
    }
    
    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = text
        label.backgroundColor = .lightGray.withAlphaComponent(0.75)
        return label
    }
    
    private func makeDetailItemView(key: String, value: String) -> LogDetailsItemView {
        let view = Bundle.main.loadNibNamed("LogDetailsItemView", owner: nil)?.first as! LogDetailsItemView
        view.set(title: key, value: value)
        return view
    }

}

// MARK: LogDetailsItemViewDelegate

extension LogDetailsCollectionViewCell: LogDetailsItemViewDelegate {
    func onInfo(title: String) {
        delegate?.onHeaderInfo(header: title)
    }
}
