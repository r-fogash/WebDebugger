//
//  TextFormatterTests.swift
//  WebInspectorTests
//
//  Created by Robert on 20.06.2022.
//

import XCTest
@testable import WebInspector

/*
 TODO:
 1. Base64 image into image
 */
class TextFormatterTests: XCTestCase {

    func test_formatEmptyString_returnEmptyResult() {
        let sut = makeSUT()
        let result = sut.execute(highlightedRanges: [], in: "", htmlAttributes: [:])
        
        XCTAssertEqual(result, NSAttributedString())
    }
    
    func test_formatString_emptyAttributes_returnDefaultFormattedString() {
        let sut = makeSUT()
        let string = "Hello world!"
        let expected = NSAttributedString(string: string, attributes: sut.defaultAttributes)
        
        let result = sut.execute(highlightedRanges: [], in: string, htmlAttributes: [:])
        
        XCTAssertEqual(result, expected)
    }
    
    func test_searchStringAtEnd_highlightSearchedString() {
        let sut = makeSUT()
        let text = "Hello world!"
        
        let rangeOfStringFulfilledSearchCriteria = range(in: text, location: 10, length: 2)
        let rangeOfStringNotFulfilledSearchCriteria = range(in: text, location: 0, length: 10)
        
        let result = sut.execute(highlightedRanges: [rangeOfStringFulfilledSearchCriteria], in: text, htmlAttributes: [:])
        
        assertEquals(attributes: sut.defaultAttributes, in: result, range: rangeOfStringNotFulfilledSearchCriteria)
        assertEquals(attributes: sut.highlightAttributes, in: result, range: rangeOfStringFulfilledSearchCriteria)
    }
    
    func test_searchStringIsTheWholeString() {
        let sut = makeSUT()
        let text = "Hello world!"
        
        let rangeOfStringFulfilledSearchCriteria = range(in: text, location: 0, length: 12)
        
        let result = sut.execute(highlightedRanges: [rangeOfStringFulfilledSearchCriteria], in: text, htmlAttributes: [:])

        assertEquals(attributes: sut.highlightAttributes, in: result, range: rangeOfStringFulfilledSearchCriteria)
    }
    
    func test_searchResultsTextHighlightingOverridsDefaultFormatting() {
        let sut = makeSUT()
        let text = "Hello world!"
        
        let defaultTextRange1 = range(in: text, location: 0, length: 2)
        let highlightedRange1 = range(in: text, location: 2, length: 2)
        let defaultTextRange2 = range(in: text, location: 4, length: 5)
        let highlightedRange2 = range(in: text, location: 9, length: 1)
        let defaultTextRange3 = range(in: text, location: 10, length: 2)
        
        let result = sut.execute(highlightedRanges: [highlightedRange1, highlightedRange2], in: text, htmlAttributes: [:])

        assertEquals(attributes: sut.defaultAttributes, in: result, range: defaultTextRange1)
        assertEquals(attributes: sut.highlightAttributes, in: result, range: highlightedRange1)
        assertEquals(attributes: sut.defaultAttributes, in: result, range: defaultTextRange2)
        assertEquals(attributes: sut.highlightAttributes, in: result, range: highlightedRange2)
        assertEquals(attributes: sut.defaultAttributes, in: result, range: defaultTextRange3)
    }
    
    func test_highlightTagOptionKeyAndValue() {
        let sut = makeSUT()
        let text = "<html key=\"value\"></html>"
        
        let result = sut.execute(highlightedRanges: [], in: text, htmlAttributes: ["key":"value"])
        
        let expectedTagOptionKeyRange = range(in: text, location: 6, length: 3)
        let expectedTagOptionValueRange = range(in: text, location: 11, length: 5)
        
        assertEquals(attributes: sut.attributeKeyAttributes, in: result, range: expectedTagOptionKeyRange)
        assertEquals(attributes: sut.attributeValueAttributes, in: result, range: expectedTagOptionValueRange)
    }
    
    func test_highlightedTagOptionsDoesNotConflictWithDefaultFormatting() {
        let sut = makeSUT()
        let text = "<html key=\"value\"></html>"
        
        let result = sut.execute(highlightedRanges: [], in: text, htmlAttributes: ["key":"value"])
        
        // '<html '
        assertEquals(attributes: sut.defaultAttributes, in: result, range: range(in: text, location: 0, length: 6))
        // '="'
        assertEquals(attributes: sut.defaultAttributes, in: result, range: range(in: text, location: 9, length: 2))
        // '"></html>'
        assertEquals(attributes: sut.defaultAttributes, in: result, range: range(in: text, location: 16, length: 9))
    }
    
    func test_searchStringResultsFormattingOverridesHTMLTagKeyFormatting() {
        let sut = makeSUT()
        let text = "<html key=\"value\"></html>"
        
        let expectedTagOptionKeyRange = range(in: text, location: 6, length: 3)
        let expectedTagOptionValueRange = range(in: text, location: 11, length: 5)
        
        let result = sut.execute(highlightedRanges: [expectedTagOptionKeyRange], in: text, htmlAttributes: ["key":"value"])
        
        assertEquals(attributes: sut.highlightAttributes, in: result, range: expectedTagOptionKeyRange)
        assertEquals(attributes: sut.attributeValueAttributes, in: result, range: expectedTagOptionValueRange)
    }
    
    func test_searchResultsFormattingOverridsHTMLTagKeyFormatting() {
        let sut = makeSUT()
        let text = "<html key=\"value\"></html>"
        
        let expectedTagOptionKeyRange = range(in: text, location: 6, length: 3)
        let expectedTagOptionValueRange = range(in: text, location: 11, length: 5)
        
        let result = sut.execute(highlightedRanges: [expectedTagOptionValueRange], in: text, htmlAttributes: ["key":"value"])
        
        assertEquals(attributes: sut.attributeKeyAttributes, in: result, range: expectedTagOptionKeyRange)
        assertEquals(attributes: sut.highlightAttributes, in: result, range: expectedTagOptionValueRange)
    }
    
    func test_a() {
        let sut = makeSUT()
        let text = "<div jsname=\"QA0Szd\" class=\"emdozc\" id=\"nd_1\" aria-label=\"Панель навігації\" role=\"menu\"></div>"
        var attributedText = AttributedString(text)
        attributedText.font = UIFont.systemFont(ofSize: 17)
        
        attributedText[attributedText.range(of: "jsname")!].foregroundColor = .blue
        attributedText[attributedText.range(of: "QA0Szd")!].foregroundColor = .red
        attributedText[attributedText.range(of: "class")!].foregroundColor = .yellow
        attributedText[attributedText.range(of: "emdozc")!].foregroundColor = .yellow
        attributedText[attributedText.range(of: "id")!].font = .systemFont(ofSize: 18)
        attributedText[attributedText.range(of: "nd_1")!].font = .systemFont(ofSize: 17)
        attributedText[attributedText.range(of: "aria-label")!].font = .systemFont(ofSize: 20)
        attributedText[attributedText.range(of: "Панель навігації")!].backgroundColor = .cyan
        
        let range = text.range(of: "role", options: [], locale: .current)!
        
//        let lower = text.distance(from: text.startIndex, to: range.lowerBound)
//        let upper = text.distance(from: text.startIndex, to: range.upperBound)
        
        let aLower = AttributedString.Index(range.lowerBound, within: attributedText)!
        let aUpper = AttributedString.Index(range.upperBound, within: attributedText)!
        
        //XCTAssertEqual(attributedText[aLower..<aUpper], )
        
        let a = attributedText[aLower..<aUpper]
        XCTAssertEqual(String(a.characters), "role")
    }
    
    func assertEquals(attributes: [NSAttributedString.Key : Any], in attributedString: NSAttributedString, range: Range<String.Index>) {
        let location = attributedString.string.distance(from: attributedString.string.startIndex, to: range.lowerBound)
        let length = attributedString.string.distance(from: attributedString.string.startIndex, to: range.upperBound) - location
        let convertedRange = NSRange(location: location, length: length)
        
        let rangeOfWholeString = NSRange(location: 0, length: attributedString.string.count)
        var rangePointer = NSRange(location: NSNotFound, length: 0)
        let resultAttributes = attributedString.attributes(at: convertedRange.location, longestEffectiveRange: &rangePointer, in: rangeOfWholeString)
        
        XCTAssertEqual(resultAttributes as NSDictionary, attributes as NSDictionary)
        XCTAssertEqual(rangePointer, convertedRange)
    }
    
    func makeSUT() -> DefaultTextFormatter {
        DefaultTextFormatter()
    }

}

