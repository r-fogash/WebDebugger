//
//  RawHTMLNode.swift
//  WebInspector
//
//  Created by Robert on 25.05.2022.
//

import Foundation

typealias RawHTMLNode = [AnyHashable : Any]

extension RawHTMLNode {
    var html: String { self["html"] as? String ?? "" }
    var children: [RawHTMLNode] {
        guard let children = self["children"] as? [RawHTMLNode], !children.isEmpty else {
            return []
        }
        return children
    }
    var isEmpty: Bool { html.isEmpty && children.isEmpty }
}

func convertToHTMLNode(rawHTMLNode: RawHTMLNode) -> HTMLNode {
    if rawHTMLNode.children.isEmpty {
        let attributes = rawHTMLNode["attributes"] as? [String:String]
        return HTMLNode(text: rawHTMLNode.html, child: [], attributes: attributes ?? [:])
    }
    
    var children = [HTMLNode]()
    
    for child in rawHTMLNode.children.filter({ !$0.isEmpty }) {
        children.append(convertToHTMLNode(rawHTMLNode: child))
    }
    
    let attributes = rawHTMLNode["attributes"] as? [String:String]
    return HTMLNode(text: rawHTMLNode.html, child: children, attributes: attributes ?? [:])
}
