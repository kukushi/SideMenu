//
//  BaseTest.swift
//  SideMenuExampleUITests
//
//  Created by kukushi on 2018/4/20.
//  Copyright © 2018 kukushi. All rights reserved.
//

import XCTest

extension XCTestCase {

    /// Validates that given element is visible/invisible
    ///
    /// - Parameters:
    ///   - element: the element
    ///   - isVisible: true - if need to check if visible, false - if hidden
    internal func assert(element: XCUIElement, isVisible: Bool, file: String = #file, line: Int = #line) {
        var visible = element.exists && element.isHittable
        visible = isVisible ? visible : !visible
        UIAssert(visible, "elements should be \(isVisible ? "visible" : "invisible")", file: file, line: line)
    }

    func UIAssert(_ value: Bool, _ description: String = "-", file: String = #file, line: Int = #line) {
        if !value {
            record(XCTIssue(type: .assertionFailure, compactDescription: description))
        }
    }

    /// waits for element to appear
    func waitForElementToAppear(_ element: XCUIElement, file: String = #file, line: Int = #line) {
        let predicate = NSPredicate(format: "exists == true AND isHittable == true")
        waitFor(element, to: predicate, trueOrFalse: true, timeout: 5, file: file, line: line)
    }

    func waitForElementToDisappear(_ element: XCUIElement, file: String = #file, line: Int = #line) {
        let predicate = NSPredicate(format: "isHittable == false")
        waitFor(element, to: predicate, trueOrFalse: false, timeout: 5, file: file, line: line)
    }

    func waitFor(_ element: XCUIElement,
                 to: NSPredicate,
                 trueOrFalse: Bool,
                 timeout: TimeInterval,
                 file: String = #file,
                 line: Int = #line) {
        expectation(for: to, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if error != nil {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.record(XCTIssue(type: .assertionFailure, compactDescription: message))
            }
        }
    }

}
