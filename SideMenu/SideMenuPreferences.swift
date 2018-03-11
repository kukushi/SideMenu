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
    
    /// The Changes that will apply to the status bar when the menu is revealed or hidden
    ///
    /// - none: Nothing will happen to the status bar. That's the default behavior.
    /// - slide: Status bar will slide up when revealed and slide down when hidden
    /// - fade: Status bar will fade out when revealed and show up when hidden
    /// - hideOnMenu: The status bar on the side menu will be hidden (without animation)
    ///               while the one the on content view will still show
    public enum StatusBarBehavior {
        case none
        case slide
        case fade
        case hideOnMenu
    }
    
    
    /// The direction where menu will show up from
    ///
    /// - left: Side menu will reveal from the left side.
    /// - right: Side menu will reveal from the right side.
    public enum MenuDirection {
        case left
        case right
    }
    
    
    /// The menu view position compared to the content view.
    ///
    /// - above: Menu view is placed above the content view.
    /// - under: Menu view is placed below the content view.
    /// - sideBySide: Menu view is placed in the same layer with the content view.
    public enum MenuPosition {
        case above
        case under
        case sideBySide
    }
    
    public struct Animation {
        // The animation interval of revealing side menu
        public var revealDuration: TimeInterval = 0.4
        
        // The animation interval of hiding side menu
        public var hideDuration: TimeInterval = 0.4
        
        // The animation option of reveal/hide
        public var options: UIViewAnimationOptions = .curveEaseOut
        
        // Same with UIView animation's usingSpringDamping
        public var usingSpringDamping: CGFloat = 1
        
        // Same with UIView animation's initialSpringVelocity
        public var initialSpringVelocity: CGFloat = 1
        
        // Whether should show shadow on content view when revealing
        public var shouldShowShadowWhenRevealing = true
        
        // The shadow's alpha when showing on the content view
        public var menuShadowAlpha: CGFloat = 0.2
    }
    
    public struct Configuration {
        /// The width of the side menu
        public var menuWidth: CGFloat = 300
        
        /// The position of the side menu
        public var position: MenuPosition = .above
        
        /// THe direction of side menu
        public var direction: MenuDirection = .left
        
        /// The status bar behavior when menu revealed / hidden
        public var statusBarBehavior: StatusBarBehavior = .none
        
        /// Whether the pan gesture is enabled.
        public var enablePanGesture = true
        
        /// If enabled, the menu view will act like rubber when reaching the border.
        public var enableRubberEffectWhenPanning = true
        
        /// If enabled, the menu view will hidden when the app entering background
        public var dismissMenuWhenEnteringBackground = false
        
        /// The cache key for
        public var defaultCacheKey: String?
    }
    
    public var basic = Configuration()
    public var animation = Animation()
}
