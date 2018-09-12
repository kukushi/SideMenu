//
//  UIView+Container.swift
//  SideMenu
//
//  Created by kukushi on 2018/9/12.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    var parentNavigationController: UINavigationController? {
        let currentViewController = parentViewController
        if let navigationController = currentViewController as? UINavigationController {
            return navigationController
        }
        return currentViewController?.navigationController
    }
}
