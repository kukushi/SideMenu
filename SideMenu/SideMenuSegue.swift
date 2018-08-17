//
//  SideMenuSegue.swift
//  SideMenu
//
//  Created by kukushi on 2018/8/8.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

/// Custom Segue that is required for SideMenuController to be used in Storyboard.
open class SideMenuSegue: UIStoryboardSegue {
    public enum ContentType: String {
        case content = "SideMenu.Content"
        case menu = "SideMenu.Menu"
    }

    public var contentType = ContentType.content

    open override func perform() {
        guard let sideMenuController = source as? SideMenuController else {
            return
        }

        switch contentType {
        case .content:
            sideMenuController.contentViewController = destination
        case .menu:
            sideMenuController.menuViewController = destination
        }
    }

}
