//
//  RichTextCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 27.06.2022.
//

import UIKit

class RichTextCollectionViewCell: UICollectionViewCell, ExpandableCollectionViewCell, TextFrameAbleCollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var disclosureIndicator: UIButton!
    
    static let reuseIdentifier = "RichTextCollectionViewCell"
    
    weak var delegate: RichTextCollectionViewCellDelegate?
    
    var isExpanded: Bool = false {
        didSet { adjustDisclosureIndicator() }
    }
    
    var level: Int = 0 {
        didSet {
            self.directionalLayoutMargins.leading = CGFloat(10 * level)
            self.layoutMarginsDidChange()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.preservesSuperviewLayoutMargins = true
        textView.textContainerInset = .zero
    }
    
    @IBAction func onDisclosureTouch(_ sender: UIButton) {
        delegate?.onDisclosure(cell: self)
    }
    
    func configure(attributedText: NSAttributedString, showDisclosure: Bool) {
        textView.attributedText = attributedText
        disclosureIndicator.isHidden = !showDisclosure
    }
    
    func rectOfText(range: Range<String.Index>, field: String?) -> CGRect {
        let rect = textView.rect(of: range)
        return contentView.convert(rect, from: textView)
    }
    
    private func adjustDisclosureIndicator() {
        disclosureIndicator.configuration?.image = UIImage.disclosureImage(isExpanded: isExpanded)
    }
    
}
