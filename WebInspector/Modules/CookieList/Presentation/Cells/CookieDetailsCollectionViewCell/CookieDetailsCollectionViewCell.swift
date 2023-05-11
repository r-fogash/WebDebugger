//
//  CookieDetailsCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 29.06.2022.
//

import UIKit
import WebKit

// TODO: Date formatter

class CookieDetailsCollectionViewCell: UICollectionViewCell, TextFrameAbleCollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    private var cookieItem: Cookie!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.preservesSuperviewLayoutMargins = true
        layoutMargins = .init(top: 0, left: 20, bottom: 0, right: -30)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func set(cookie: Cookie, highlightInfo: [String:[Range<String.Index>]], textFormatter: TextFormatter) {
        cookieItem = cookie
        
        var isAccentColored = false
        
        for detailItem in cookieItem.attributes {
            isAccentColored.toggle()
            addCookieItem(property: detailItem.name, value: detailItem.value, highlightedRanges: highlightInfo[detailItem.name.rawValue] ?? [], isAccentColored: isAccentColored, textFormatter: textFormatter)
        }
    }
    
    func rectOfText(range: Range<String.Index>, field: String?) -> CGRect {
        guard let field else { return .zero }
        guard let item = stackView.arrangedSubviews
            .filter({ view in view is CookieDetailItemView })
            .first(where: { view in (view as? CookieDetailItemView)?.keyNameLabel.text == field })
                as? CookieDetailItemView
        else {
            return .zero
        }
        let rect = rectOfText(range: range, in: item)
        return self.contentView.convert(rect, from: item.valueTextView)
    }
    
    private func rectOfText(range: Range<String.Index>, in view: CookieDetailItemView ) -> CGRect {
        guard let attributedString = view.valueTextView.attributedText else {
            return CGRect.zero
        }
        let location = attributedString.string.distance(from: attributedString.string.startIndex, to: range.lowerBound)
        let length = attributedString.string[range].unicodeScalars.count
        let nsRange = NSRange(location: location, length: length)
        
        var glyphRange = NSRange()
        view.valueTextView.layoutManager.characterRange(forGlyphRange: nsRange, actualGlyphRange: &glyphRange)
        
        var rect = view.valueTextView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: view.valueTextView.textContainer)
        rect.origin.y += view.valueTextView.textContainerInset.top
        rect.origin.x += view.valueTextView.textContainerInset.left
        return rect
    }
    
    private func addCookieItem(property: HTTPCookiePropertyKey, value: String, highlightedRanges:[Range<String.Index>], isAccentColored: Bool, textFormatter: TextFormatter) {
        let item = loadCookieDetailItemView()
        item.keyNameLabel.text = property.rawValue
        item.valueTextView.attributedText = textFormatter.execute(highlightedRanges: highlightedRanges, in: value, htmlAttributes: [:])
        item.backgroundColor = isAccentColored ? UIColor(named: "accent_true") : UIColor(named: "accent_false")
        stackView.addArrangedSubview(item)
    }
    
    private func loadCookieDetailItemView() -> CookieDetailItemView {
        Bundle.main.loadNibNamed("CookieDetailItemView", owner: nil)!.first as! CookieDetailItemView
    }

}
