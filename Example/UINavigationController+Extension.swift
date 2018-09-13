//
//  UINavigationController+Extension.swift
//  SideMenuExample
//
//  Created by kukushi on 25/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
