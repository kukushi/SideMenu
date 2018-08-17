//
//  SideMenuExampleUITests.swift
//  SideMenuExampleUITests
//
//  Created by kukushi on 2018/4/8.
//  Copyright © 2018 kukushi. All rights reserved.
//

import XCTest
import SideMenu

class SideMenuBasicUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRevealAndHide() {
        let app = XCUIApplication()
        let menuView = app.tables.containing(.staticText, identifier: "SIDEMENU").element

        assert(element: menuView, isVisible: false)

        // Show
        app.navigationBars["Preferences"].buttons["Menu"].tap()

        waitForElementToAppear(menuView)

        // Hide
        let element = app.otherElements["ContentShadowOverlay"]
        element.tap()

        print(app.debugDescription)

        waitForElementToDisappear(menuView)
    }

}
