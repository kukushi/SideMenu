//
//  AppDelegate.swift
//  SideMenuExample
//
//  Created by kukushi on 11/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        var arguments = ProcessInfo.processInfo.arguments
        arguments.removeFirst()
        setupTestingEnvironment(with: arguments)
        #endif

        configureSideMenu()
        return true
    }

    private func configureSideMenu() {
        SideMenuController.preferences.basic.menuWidth = 240
        SideMenuController.preferences.basic.defaultCacheKey = "0"
    }

}

#if DEBUG
extension AppDelegate {
    private func setupTestingEnvironment(with arguments: [String]) {
        if arguments.contains("SwitchToRight") {
            SideMenuController.preferences.basic.direction = .right
        }
    }
}
#endif
