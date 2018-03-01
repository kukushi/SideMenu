//
//  SideMenuController.swift
//  SideMenu
//
//  Created by kukushi on 10/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// MARK: Delegates

public protocol SideMenuControllerDelegate: class {
    func sideMenuWillShow(_ sideMenu: SideMenuController)
    func sideMenuDidShow(_ sideMenu: SideMenuController)
    func sideMenuWillHide(_ sideMenu: SideMenuController)
    func sideMenuDidHide(_ sideMenu: SideMenuController)
}

// Provides default implementation for delegates
public extension SideMenuControllerDelegate {
    func sideMenuWillShow(_ sideMenu: SideMenuController) {}
    func sideMenuDidShow(_ sideMenu: SideMenuController) {}
    func sideMenuWillHide(_ sideMenu: SideMenuController) {}
    func sideMenuDidHide(_ sideMenu: SideMenuController) {}
}

/// Custom Segue for SideMenuController
public class SideMenuSegue: UIStoryboardSegue {
    public enum SegueType: String {
        case content = "SideMenu.Content"
        case menu = "SideMenu.Menu"
    }
    
    public var type = SegueType.content
    
    public override func perform() {
        guard let sideMenuController = source as? SideMenuController else {
            return
        }
        
        switch type {
        case .content:
            sideMenuController.contentViewController = destination
        case .menu:
            sideMenuController.menuViewController = destination
        }
    }
    
}

/// The SideMenuController main class
public class SideMenuController: UIViewController {
    
    /// Configure this property to change the behavior of SideMenuController.
    /// Most changes will take effect immediately, besides the `basic.positon`.
    public static var preferences = SideMenuPreferences()
    private var preferences: SideMenuPreferences {
        return type(of: self).preferences
    }
    
    /// Storyboard
    private var isInitiatedFromStoryboard: Bool {
        return storyboard != nil
    }
    
    @IBInspectable public var contentID: String = SideMenuSegue.SegueType.content.rawValue
    @IBInspectable public var menuID: String = SideMenuSegue.SegueType.menu.rawValue

    /// Caching
    private lazy var lazyCachedViewControllerClosures: [String: () -> UIViewController?] = [:]
    private lazy var lazyCachedViewControllers: [String: UIViewController] = [:]
    
    public weak var delegate: SideMenuControllerDelegate?
    
    public var contentViewController: UIViewController? {
        didSet {
            guard contentViewController !== oldValue else {
                return
            }
            
            load(contentViewController, on: contentContainerView)
            contentContainerView.sendSubview(toBack: contentViewController!.view)
            unload(oldValue)
            
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    public var menuViewController: UIViewController?

    private let menuContainerView = UIView()
    private let contentContainerView = UIView()
    private var statusBarScreenShotView: UIView?
    
    /// Whether the menu is revealing
    public var isMenuRevealed = false
    
    private var shouldShowShadowOnContent: Bool {
        return preferences.animation.shouldShowShadowWhenRevealing
            && preferences.basic.position == .above
    }
    private var startFrameX: CGFloat = 0

    /// The view responsible for tapping to hide the menu and shadow
    weak private var contentContainerOverlay: UIView?
    
    // MARK: Initalization

    convenience init(contentViewController: UIViewController, menuViewController: UIViewController) {
        self.init()
        
        self.contentViewController = contentViewController
        self.menuViewController = menuViewController
    }
    
    // MARK: Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup from the IB
        if isInitiatedFromStoryboard {
            // Note that if you are using the SideMenuController from the IB, you must supply the default or custom view controller
            // ID in the storyboard.
            performSegue(withIdentifier: contentID, sender: self)
            performSegue(withIdentifier: menuID, sender: self)
        }
        
        contentContainerView.frame = view.bounds
        view.addSubview(contentContainerView)
        
        menuContainerView.frame = sideMenuFrame(visibility: false)
        view.addSubview(menuContainerView)
        
        load(contentViewController, on: contentContainerView)
        load(menuViewController, on: menuContainerView)
        
        if preferences.basic.position == .under {
            view.bringSubview(toFront: contentContainerView)
        }
        
        // Forwarding stauts bar style/hidden status to content view controller
        setNeedsStatusBarAppearanceUpdate()
        
        if let key = preferences.basic.defaultCacheKey {
            lazyCachedViewControllers[key] = contentViewController
        }
        
        configureGestures()
    }
    
    private func configureGestures() {
        // The gesture will be added anyway, its delegate will tell whether it will work
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(SideMenuController.handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Storyboard
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segue = segue as? SideMenuSegue, let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case contentID:
            segue.type = .content
        case menuID:
            segue.type = .menu
        default:
            break
        }
    }
    
    // MARK: Show/Hide Menu
    
    /// Reveal the menu
    public func revealMenu() {
        showMenuWithOptions()
    }
    
    /// Hide the menu
    public func hideMenu() {
        hideMenuWithOptions()
    }
    
    private func hideMenuWithOptions(shouldCallDelegate: Bool = true, shouldChangeStatusBar: Bool = true) {
        menuViewController?.beginAppearanceTransition(true, animated: true)
        
        if shouldCallDelegate {
            delegate?.sideMenuWillHide(self)
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        animateMenu(with: preferences,
                    reveal: false,
                    shouldChangeStatusBar: shouldChangeStatusBar,
                    animations: {
            self.menuContainerView.frame = self.sideMenuFrame(visibility: false)
            self.contentContainerView.frame = self.contentFrame(visibility: false)
            if self.shouldShowShadowOnContent {
                self.contentContainerOverlay?.alpha = 0
            }
        }) { (finished) in
            self.menuViewController?.endAppearanceTransition()
            
            if shouldCallDelegate {
                self.delegate?.sideMenuDidHide(self)
            }
            
            self.contentContainerOverlay?.removeFromSuperview()
            self.contentContainerOverlay = nil
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.isMenuRevealed = false
        }
    }
    
    private func showMenuWithOptions(shouldCallDelegate: Bool = true, shouldChangeStatusBar: Bool = true) {
        menuViewController?.beginAppearanceTransition(true, animated: true)
        
        addContentOverlayViewIfNeeded()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if shouldCallDelegate {
            delegate?.sideMenuWillShow(self)
        }
        
        animateMenu(with: preferences,
                    reveal: true,
                    shouldChangeStatusBar: shouldChangeStatusBar,
                    animations: {
            self.menuContainerView.frame = self.sideMenuFrame(visibility: true)
            self.contentContainerView.frame = self.contentFrame(visibility: true)
            if self.shouldShowShadowOnContent {
                self.contentContainerOverlay?.alpha = self.preferences.animation.menuShadowAlpha
            }
        }) { (finished) in
            self.menuViewController?.endAppearanceTransition()
            UIApplication.shared.endIgnoringInteractionEvents()
            if shouldCallDelegate {
                self.delegate?.sideMenuDidShow(self)
            }
            
            self.isMenuRevealed = true
        }
    }
    
    @objc private func hideButtonDidClicked(_ tap: UITapGestureRecognizer) {
        hideMenu()
    }
    
    // MAKR: Gesture
    
    private func addContentOverlayViewIfNeeded() {
        guard contentContainerOverlay == nil else {
            return
        }
        
        let overlay = UIView()
        overlay.bounds = contentContainerView.bounds
        overlay.center = contentContainerView.center
        if !shouldShowShadowOnContent {
            overlay.backgroundColor = .clear
        } else {
            overlay.backgroundColor = .black
            overlay.alpha = 0
        }
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let tapToHideGesture = UITapGestureRecognizer()
        tapToHideGesture.addTarget(self, action: #selector(SideMenuController.hideButtonDidClicked(_:)))
        overlay.addGestureRecognizer(tapToHideGesture)
        
        contentContainerView.insertSubview(overlay, aboveSubview: contentViewController!.view)
        
        contentContainerOverlay = overlay
    }
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let menuWidth = preferences.basic.menuWidth
        var translation = pan.translation(in: pan.view).x
        let viewToAnimate: UIView
        let viewToAnimate2: UIView?
        let leftBorder: CGFloat
        let rightBorder: CGFloat
        let containerWidth: CGFloat
        switch preferences.basic.position {
        case .above:
            viewToAnimate = menuContainerView
            viewToAnimate2 = nil
            containerWidth = viewToAnimate.frame.width
            leftBorder = -containerWidth
            rightBorder = menuWidth - containerWidth
        case .under:
            viewToAnimate = contentContainerView
            viewToAnimate2 = nil
            containerWidth = viewToAnimate.frame.width
            leftBorder = 0
            rightBorder = menuWidth
        case .sideBySide:
            viewToAnimate = contentContainerView
            viewToAnimate2 = menuContainerView
            containerWidth = viewToAnimate.frame.width
            leftBorder = 0
            rightBorder = menuWidth
        }
        
        switch pan.state {
        case .began:
            startFrameX = viewToAnimate.frame.origin.x
            addContentOverlayViewIfNeeded()
            setStatusBar(hidden: !isMenuRevealed, animate: true)
            
        case .changed:
            let resultX = startFrameX + translation
            guard (preferences.basic.enableRubberEffectWhenPanning || resultX <= rightBorder) && resultX >= leftBorder else {
                return
            }
            
            if resultX <= rightBorder {
                viewToAnimate.frame.origin.x = resultX
            } else {
                if !isMenuRevealed {
                    translation -= menuWidth
                }
                viewToAnimate.frame.origin.x = rightBorder + (menuWidth * log10(translation / menuWidth + 1))
            }
            
            if let viewToAnimate2 = viewToAnimate2 {
                viewToAnimate2.frame.origin.x = viewToAnimate.frame.origin.x - containerWidth
            }
            
            if shouldShowShadowOnContent {
                let shadowPrecent = min(menuContainerView.frame.maxX / menuWidth, 1)
                contentContainerOverlay?.alpha = self.preferences.animation.menuShadowAlpha * shadowPrecent
            }
        case .ended, .cancelled, .failed:
            let precent: CGFloat
            switch preferences.basic.position {
            case .above:
                precent = viewToAnimate.frame.maxX / menuWidth
            case .under:
                precent = viewToAnimate.frame.minX / menuWidth
            case .sideBySide:
                precent = viewToAnimate.frame.minX / menuWidth
            }
            let decisionPoint: CGFloat = isMenuRevealed ? 0.6 : 0.4
            if precent > decisionPoint {
                showMenuWithOptions(shouldCallDelegate: !isMenuRevealed, shouldChangeStatusBar: isMenuRevealed)
            } else {
                hideMenuWithOptions(shouldCallDelegate: isMenuRevealed, shouldChangeStatusBar: !isMenuRevealed)
            }
        default:
            break
        }
    }
    
    // MARK: Status Bar
    
    private func setStatusBar(hidden: Bool, animate: Bool = false) {
        // UIKit provides `setNeedsStatusBarAppearanceUpdate` and couple of methods to animate the status bar changes.
        // The problem with this approach is it will hide the status bar and it's underlying space completely, as a result,
        // the navigation bar will go up as we don't expect.
        // So we need to manipulate the windows of status bar manually.
        
        let behavior = self.preferences.basic.statusBarBehavior
        if animate && behavior != .hideOnMenu {
            UIView.animate(withDuration: 0.4, animations: {
                UIWindow.sb?.set(hidden, with: behavior)
            })
        } else {
            UIWindow.sb?.set(hidden, with: behavior)
        }
        
        if behavior == .hideOnMenu {
            if !hidden {
                statusBarScreenShotView?.removeFromSuperview()
                statusBarScreenShotView = nil
            } else if statusBarScreenShotView == nil {
                statusBarScreenShotView = statusBarScreenShot()
                contentContainerView.insertSubview(statusBarScreenShotView!, aboveSubview: contentViewController!.view)
            }
        }
    }
    
    private func statusBarScreenShot() -> UIView? {
        let height = UIApplication.shared.statusBarFrame
        let screenshot = UIScreen.main.snapshotView(afterScreenUpdates: false)
        screenshot.frame.size.height = height.height
        screenshot.contentMode = .top
        return screenshot
    }
    
    public override var childViewControllerForStatusBarStyle: UIViewController? {
        // Forward to the content view controller
        return contentViewController
    }
    
    public override var childViewControllerForStatusBarHidden: UIViewController? {
        return contentViewController
    }
    
    // MARK: Cache
    
    /// Cache the closure with identifier. The closure will only execute when needed.
    ///
    /// - Parameters:
    ///   - viewControllerClosure: the closure generate the view controller
    ///   - identifier: identifier the cache the view controller
    public func cache(viewControllerClosure: @escaping () -> UIViewController?, with identifier: String) {
        lazyCachedViewControllerClosures[identifier] = viewControllerClosure
    }
    
    /// Cache the view controller with identifier
    ///
    /// - Parameters:
    ///   - viewController: the view controller to cache
    ///   - identifier: the identifier
    public func cache(viewController: UIViewController, with identifier: String) {
        lazyCachedViewControllers[identifier] = viewController
    }
    
    /// Change the content view controller with given identifier
    ///
    /// - Parameter identifier: the identifier
    public func setContentViewController(with identifier: String) {
        if let viewController = lazyCachedViewControllers[identifier] {
            contentViewController = viewController
        } else if let viewController = lazyCachedViewControllerClosures[identifier]?() {
            lazyCachedViewControllerClosures[identifier] = nil
            lazyCachedViewControllers[identifier] = viewController
            contentViewController = viewController
        }
    }

    /// The identifier of current content view controller, if exist
    ///
    /// - Returns: the identifier
    public func currentCacheIdentifier() -> String? {
        guard let index = lazyCachedViewControllers.values.index(of: contentViewController!) else {
            return nil
        }
        return lazyCachedViewControllers.keys[index]
    }
    
    public func clearCache(with identifier: String) {
        lazyCachedViewControllerClosures[identifier] = nil
        lazyCachedViewControllers[identifier] = nil
    }
    
    // MARK: - Helper Methods
    
    private func animateMenu(with preferences: SideMenuPreferences,
                     reveal: Bool,
                     shouldChangeStatusBar: Bool = true,
                     animations: @escaping () -> Void,
                     completion: ((Bool) -> Void)? = nil) {
        let shouldAnimateStatusBarChange = preferences.basic.statusBarBehavior != .hideOnMenu
        if shouldChangeStatusBar && !shouldAnimateStatusBarChange && reveal {
            setStatusBar(hidden: reveal)
        }
        let duration = reveal ? preferences.animation.revealDuration : preferences.animation.hideDuration
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: preferences.animation.usingSpringDamping,
                       initialSpringVelocity: preferences.animation.initialSpringVelocity,
                       options: preferences.animation.options,
        animations: {
            if shouldChangeStatusBar && shouldAnimateStatusBarChange {
                self.setStatusBar(hidden: reveal)
            }
            
            animations()
        }) { (finished) in
            if shouldChangeStatusBar && !shouldAnimateStatusBarChange && !reveal {
                self.setStatusBar(hidden: reveal)
            }
            
            completion?(finished)
        }
    }
    
    private func sideMenuFrame(visibility: Bool) -> CGRect {
        let position = preferences.basic.position
        switch position {
        case .above, .sideBySide:
            var baseFrame = view.frame
            if visibility {
                baseFrame.origin.x = preferences.basic.menuWidth - baseFrame.width
            } else {
                baseFrame.origin.x = -baseFrame.width
            }
            return baseFrame
        case .under:
            return view.frame
        }
    }
    
    private func contentFrame(visibility: Bool) -> CGRect {
        let position = preferences.basic.position
        switch position {
        case .above:
            return view.frame
        case .under, .sideBySide:
            var baseFrame = view.frame
            if visibility {
                baseFrame.origin.x = preferences.basic.menuWidth
            } else {
                baseFrame.origin.x = 0
            }
            return baseFrame
        }
    }
    
    // MARK: Container ViewController LifeCyle
    
    private func load(_ viewController: UIViewController?, on view: UIView) {
        guard let viewController = viewController else {
            return
        }
        
        addChildViewController(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    private func unload(_ viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension SideMenuController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.view == view && gestureRecognizer is UIPanGestureRecognizer {
            return self.preferences.basic.enablePanGesture
        }
        return true
    }
}
