//
//  SideMenuRightUITests.swift
//  SideMenuExampleUITests
//
//  Created by kukushi on 2018/5/15.
//  Copyright © 2018 kukushi. All rights reserved.
//

import XCTest

class SideMenuRightUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["SwitchToRight"]
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRevealAndHide() {
        let app = XCUIApplication()
        let menuView = app.tables.containing(.staticText, identifier: "SIDEMENU").element

        assert(element: menuView, isVisible: false)

        // Show
        app.navigationBars["Preferences"].buttons["Menu"].tap()

        waitForElementToAppear(menuView)

        print(menuView.debugDescription)

        // Hide
        let element = app.otherElements["ContentShadowOverlay"]
        element.tap()

        print(app.debugDescription)

        waitForElementToDisappear(menuView)
    }

}
