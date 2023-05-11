//
//  URLStringRefiner.swift
//  WebInspector
//
//  Created by Robert on 08.05.2023.
//

import Foundation

protocol URLStringRefiner {
    func execute(_ urlString: String?) -> URL?
}
