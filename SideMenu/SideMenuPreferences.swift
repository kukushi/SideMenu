//
//  SideMenuPreferences.swift
//  SideMenu
//
//  Created by kukushi on 21/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import Foundation


/// The preferences of SideMenuController
public struct SideMenuPreferences {
    public enum StatusBarBehavior {
        case none
        case slide
        case fade
        case hideOnMenu
    }
    
    public struct Animation {
        public var revealDuration: TimeInterval = 0.4
        public var hideDuration: TimeInterval = 0.4
        public var options: UIViewAnimationOptions = .curveEaseOut
        public var usingSpringDamping: CGFloat = 1
        public var initialSpringVelocity: CGFloat = 1
        public var shouldShowShadowWhenRevealing = true
        public var menuShadowAlpha: CGFloat = 0.2
    }
    
    public struct Configuration {
        public var menuWidth: CGFloat = 300
        public var statusBarBehavior: StatusBarBehavior = .none
        public var enablePanGesture = true
        public var enableRubberEffectWhenPanning = true
        public var defaultCacheKey: String?
    }
    
    public var basic = Configuration()
    public var animation = Animation()
}
