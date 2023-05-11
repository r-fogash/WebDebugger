//
//  UIImageView+disclosure.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import UIKit

extension UIImage {
    static func disclosureImage(isExpanded: Bool) -> UIImage {
        UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")!
    }
}
