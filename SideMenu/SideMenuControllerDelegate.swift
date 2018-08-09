//
//  SideMenuControllerDelegate.swift
//  SideMenu
//
//  Created by kukushi on 2018/8/8.
//  Copyright © 2018 kukushi. All rights reserved.
//

import Foundation

// Delegate Methods
public protocol SideMenuControllerDelegate: class {
    
    // MARK: Animation
    
    /// Called to allow the delegate to return a noninteractive animator object for use during view controller transitions. Same with
    /// UIKit's `navigationController:animationControllerForOperation:fromViewController:toViewController:`.
    ///
    /// - Parameters:
    ///   - sideMenuController: The side menu controller
    ///   - fromVC: The currently visible view controller.
    ///   - toVC: The view controller that should be visible at the end of the transition.
    /// - Returns: The animator object responsible for managing the transition animations, or nil if you want to use the fade transitions.
    func sideMenu(_ sideMenuController: SideMenuController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    // MARK: Revealing
    
    /// Side menu is going to reveal.
    ///
    /// - Parameter sideMenu: The side menu
    func sideMenuWillReveal(_ sideMenu: SideMenuController)
    
    /// Side menu did revealed.
    ///
    /// - Parameter sideMenu: The side menu
    func sideMenuDidReveal(_ sideMenu: SideMenuController)
    
    /// Side menu is going to hide.
    ///
    /// - Parameter sideMenu: The side menu
    func sideMenuWillHide(_ sideMenu: SideMenuController)
    
    /// Side menu is did hide.
    ///
    /// - Parameter sideMenu: The side menu
    func sideMenuDidHide(_ sideMenu: SideMenuController)
}

// Provides default implementation for delegates
public extension SideMenuControllerDelegate {
    func sideMenu(_ sideMenuController: SideMenuController, animationControllerFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func sideMenuWillReveal(_ sideMenu: SideMenuController) {}
    func sideMenuDidReveal(_ sideMenu: SideMenuController) {}
    func sideMenuWillHide(_ sideMenu: SideMenuController) {}
    func sideMenuDidHide(_ sideMenu: SideMenuController) {}
}
