//
//  UIViewController+Extension.swift
//  SideMenu
//
//  Created by kukushi on 10/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// Provides aceess to the side menu controller
public extension UIViewController {
    
    /// Access the side menu controller
    public var sm_sideMenuController: SideMenuController? {
        return getSideMenuController(self)
    }
    
    fileprivate func getSideMenuController(_ viewController: UIViewController) -> SideMenuController? {
        var sourceViewController: UIViewController? = viewController
        repeat {
            if let parent = sourceViewController?.parent, parent is SideMenuController {
                return parent as? SideMenuController
            }
            sourceViewController = parent
        } while (sourceViewController != nil)
        return nil
    }
}
