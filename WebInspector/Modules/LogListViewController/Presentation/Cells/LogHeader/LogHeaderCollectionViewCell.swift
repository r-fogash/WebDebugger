//
//  LogHeaderCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 04.07.2022.
//

import UIKit

class LogHeaderCollectionViewCell: UICollectionViewCell, ExpandableCollectionViewCell {
    
    @IBOutlet weak var disclosureImageView: UIImageView!
    
    var isExpanded: Bool = false {
        didSet { updateDisclosureImage() }
    }
    
    private func updateDisclosureImage() {
        disclosureImageView.image = UIImage.disclosureImage(isExpanded: isExpanded)
    }
    
}
