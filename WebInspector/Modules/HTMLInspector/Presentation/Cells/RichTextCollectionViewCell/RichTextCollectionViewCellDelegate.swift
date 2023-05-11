//
//  RichTextCollectionViewCellDelegate.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import UIKit

protocol RichTextCollectionViewCellDelegate: AnyObject
{
    func onDisclosure(cell: ExpandableCollectionViewCell)
}
