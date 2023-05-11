//
//  TextFrameAbleCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import UIKit

protocol TextFrameAbleCollectionViewCell: UICollectionViewCell {
    func rectOfText(range: Range<String.Index>, field: String?) -> CGRect
}
