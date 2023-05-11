//
//  TestUtils.swift
//  WebInspectorTests
//
//  Created by Robert on 24.06.2022.
//

import XCTest

extension XCTestCase {
    func range(in text: String, location: Int, length: Int) -> Range<String.Index> {
        let start = text.index(text.startIndex, offsetBy: location)
        let end = text.index(start, offsetBy: length)
        return start..<end
    }
}
