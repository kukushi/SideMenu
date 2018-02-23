//
//  UIViewController+Extension.swift
//  SideMenu
//
//  Created by kukushi on 10/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// Provides helpers methods for view controller
public extension UIViewController {
    
    /// Access the side menu controller
    public var sm_sideMenuController: SideMenuController? {
        return getSideMenuController(self)
    }
    
    fileprivate func getSideMenuController(_ viewController: UIViewController) -> SideMenuController? {
        if let parent = viewController.parent {
            if let parent = parent as? SideMenuController {
                return parent
            } else {
                return getSideMenuController(parent)
            }
        }
        return nil
    }
}
