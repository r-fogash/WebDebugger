//
//  LogDetailsItemView.swift
//  WebInspectorApp
//
//  Created by Robert on 04.07.2022.
//

import UIKit

protocol LogDetailsItemViewDelegate: AnyObject
{
    func onInfo(title: String)
}

class LogDetailsItemView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextView: UITextView!
    @IBOutlet weak var infoButton: UIButton!
    
    weak var delegate: LogDetailsItemViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueTextView.textContainerInset = .zero
    }
    
    func set(title: String, value: String) {
        titleLabel.text = title
        valueTextView.text = value
    }
    
    @IBAction func onInfo(_ sender: UIButton) {
        delegate?.onInfo(title: titleLabel.text ?? "")
    }
}
