//
//  HTMLNode.swift
//  WebInspector
//
//  Created by Robert on 25.05.2022.
//

import Foundation

struct HTMLNode: Hashable {
    let identifier = UUID()
    let text: String
    let child: [HTMLNode]
    let attributes: [String: String]
}
