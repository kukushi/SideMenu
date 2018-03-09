//
//  UINavigationController+Extension.swift
//  SideMenuExample
//
//  Created by kukushi on 25/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
