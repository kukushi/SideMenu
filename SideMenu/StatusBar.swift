//
//  StatusBar.swift
//  SideMenu
//
//  Created by kukushi on 22/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

extension UIWindow {
    static var sb: UIWindow? {
        let s = "status", b = "Bar", w = "Window"
        return UIApplication.shared.value(forKey: s+b+w) as? UIWindow
    }
    
    func set(_ hidden: Bool, with behavior: SideMenuPreferences.StatusBarBehavior) {
        guard behavior != .none else {
            return
        }
        
        switch behavior {
        case .fade, .hideOnMenu:
            alpha = hidden ? 0 : 1
        case .slide:
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            transform = hidden ? CGAffineTransform(translationX: 0, y: -statusBarHeight) : CGAffineTransform.identity
        default:
            return
        }
    }
}
