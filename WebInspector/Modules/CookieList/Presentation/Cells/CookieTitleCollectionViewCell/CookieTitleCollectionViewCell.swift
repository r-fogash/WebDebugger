//
//  CookieTitleCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 29.06.2022.
//

import UIKit

class CookieTitleCollectionViewCell: UICollectionViewCell, ExpandableCollectionViewCell {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var disclosureButton: UIButton!
    
    var isExpanded: Bool = false {
        didSet { disclosureButton.configuration?.image = UIImage.disclosureImage(isExpanded: isExpanded) }
    }

}
