//
//  CookieDetailItemView.swift
//  WebInspector
//
//  Created by Robert on 29.06.2022.
//

import UIKit

class CookieDetailItemView: UIView {

    @IBOutlet weak var keyNameLabel: UILabel!
    @IBOutlet weak var valueTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueTextView.textContainerInset = .zero
    }
    
}
