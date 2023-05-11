//
//  HTMLNodesExtractor.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import Foundation
import Combine

protocol HTMLNodesExtractor {
    func execute() -> Future<HTMLNode, Error>
}
