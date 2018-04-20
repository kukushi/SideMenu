//
//  SideMenuExampleUITests.swift
//  SideMenuExampleUITests
//
//  Created by kukushi on 2018/4/8.
//  Copyright © 2018 kukushi. All rights reserved.
//

import XCTest
import SideMenu

class SideMenuExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRevealAndHide() {
        let app = XCUIApplication()
        let menuView = app.tables.containing(.staticText, identifier:"SIDEMENU").element
        
        assert(element: menuView, isVisible: false)
        
        // Show
        app.navigationBars["Preferences"].buttons["Menu"].tap()
        
        waitForElementToAppear(menuView)
        
        // Hide
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1)
        element.tap()
        
        waitForElementToDisappear(menuView)
    }
    
}
