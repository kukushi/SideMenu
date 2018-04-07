//
//  UIViewController+Extension.swift
//  SideMenu
//
//  Created by kukushi on 10/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// Provides access to the side menu controller
public extension UIViewController {
    
    /// Access the nearest ancestor view controller hierarchy that is a side menu controller.
    public var sideMenuController: SideMenuController? {
        return findSideMenuController(from: self)
    }
    
    @available(*, deprecated, message: "Renamed to `sideMenuController`.")
    /// `SideMenu` currently doesn't support ObjC, therefore the prefix was removed.
    public var sm_sideMenuController: SideMenuController? {
        return sideMenuController
    }
    
    fileprivate func findSideMenuController(from viewController: UIViewController) -> SideMenuController? {
        var sourceViewController: UIViewController? = viewController
        repeat {
            sourceViewController = sourceViewController?.parent
            if let sideMenuController = sourceViewController as? SideMenuController {
                return sideMenuController
            }
        } while (sourceViewController != nil)
        return nil
    }
}
