//
//  ExpandableCollectionViewCell.swift
//  WebInspector
//
//  Created by Robert on 10.05.2023.
//

import UIKit

protocol ExpandableCollectionViewCell: UICollectionViewCell {
    var isExpanded: Bool { get set }
}
