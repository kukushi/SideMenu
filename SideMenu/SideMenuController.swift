//
//  SideMenuController.swift
//  SideMenu
//
//  Created by kukushi on 10/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

// MARK: Delegate

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
    public enum ContentType: String {
        case content = "SideMenu.Content"
        case menu = "SideMenu.Menu"
    }
    
    public var contentType = ContentType.content
    
    public override func perform() {
        guard let sideMenuController = source as? SideMenuController else {
            return
        }
        
        switch contentType {
        case .content:
            sideMenuController.contentViewController = destination
        case .menu:
            sideMenuController.menuViewController = destination
        }
    }
    
}

/// A container view controller owns a menu view controller and a content view controller.
public class SideMenuController: UIViewController {
    
    /// Configure this property to change the behavior of SideMenuController;
    /// Most changes will take effect immediately, besides the `basic.positon`.
    public static var preferences = SideMenuPreferences()
    private var preferences: SideMenuPreferences {
        return type(of: self).preferences
    }
    
    private var isInitiatedFromStoryboard: Bool {
        return storyboard != nil
    }
    
    /// The identifier of content view controller segue. If the SideMenuController instance is initiated from IB, this identifier will
    /// be used to retrieve the content view controller.
    @IBInspectable public var contentSegueID: String = SideMenuSegue.ContentType.content.rawValue
    
    /// The identifier of menu view controller segue. If the SideMenuController instance is initiated from IB, this identifier will
    /// be used to retrieve the menu view controller.
    @IBInspectable public var menuSegueID: String = SideMenuSegue.ContentType.menu.rawValue

    /// Caching
    private lazy var lazyCachedViewControllerGenerators: [String: () -> UIViewController?] = [:]
    private lazy var lazyCachedViewControllers: [String: UIViewController] = [:]
    
    /// The delegate.
    public weak var delegate: SideMenuControllerDelegate?
    
    /// The content view controller. Changes its value will change the display immediately.
    /// If you want a caching approach, use `setContentViewController(with)`
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
    public var menuViewController: UIViewController? {
        didSet {
            guard menuViewController !== oldValue else {
                return
            }
            
            load(menuViewController, on: menuContainerView)
            unload(oldValue)
        }
    }
    
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
    
    // MARK: Initialization

    /// Creates a SideMenuController instance with the content view controller and menu view controller.
    ///
    /// - Parameters:
    ///   - contentViewController: the content view controller
    ///   - menuViewController: the menu view controller
    public convenience init(contentViewController: UIViewController, menuViewController: UIViewController) {
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
            performSegue(withIdentifier: contentSegueID, sender: self)
            performSegue(withIdentifier: menuSegueID, sender: self)
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
        
        // Forwarding status bar style/hidden status to content view controller
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
        case contentSegueID:
            segue.contentType = .content
        case menuSegueID:
            segue.contentType = .menu
        default:
            break
        }
    }
    
    // MARK: Reveal/Hide Menu
    
    /// Reveals the menu.
    public func revealMenu() {
        showMenuWithOptions()
    }
    
    /// Hides the menu.
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
    
    // MARK: Gesture
    
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
        let isLeft = preferences.basic.direction == .left
        var translation = pan.translation(in: pan.view).x
        let viewToAnimate: UIView
        let viewToAnimate2: UIView?
        var leftBorder: CGFloat
        var rightBorder: CGFloat
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
        
        if !isLeft {
            swap(&leftBorder, &rightBorder)
            leftBorder *= -1
            rightBorder *= -1
        }
        
        switch pan.state {
        case .began:
            startFrameX = viewToAnimate.frame.origin.x
            addContentOverlayViewIfNeeded()
            // If status bar behavior is not `.none`, status bar will always be hidden when paning.
            setStatusBar(hidden: true, animate: true)
        case .changed:
            let resultX = startFrameX + translation
            let notReachLeftBorder = (!isLeft && preferences.basic.enableRubberEffectWhenPanning) || resultX >= leftBorder
            let notReachRightBorder = (isLeft && preferences.basic.enableRubberEffectWhenPanning) || resultX <= rightBorder
            guard notReachLeftBorder && notReachRightBorder else {
                return
            }
            
            let factor: CGFloat = isLeft ? 1 : -1
            let notReachDesiredBorder = isLeft ? resultX <= rightBorder : resultX >= leftBorder
            if notReachDesiredBorder {
                viewToAnimate.frame.origin.x = resultX
            } else {
                if !isMenuRevealed {
                    translation -= menuWidth * factor
                }
                viewToAnimate.frame.origin.x = (isLeft ? rightBorder : leftBorder) + factor * menuWidth * log10(translation * factor / menuWidth + 1) * 0.5
            }
            
            if let viewToAnimate2 = viewToAnimate2 {
                viewToAnimate2.frame.origin.x = viewToAnimate.frame.origin.x - containerWidth * factor
            }
            
            if shouldShowShadowOnContent {
                let shadowPercent = min(menuContainerView.frame.maxX / menuWidth, 1)
                contentContainerOverlay?.alpha = self.preferences.animation.menuShadowAlpha * shadowPercent
            }
        case .ended, .cancelled, .failed:
            let offset: CGFloat
            switch preferences.basic.position {
            case .above:
                offset = isLeft ? viewToAnimate.frame.maxX : containerWidth - viewToAnimate.frame.minX
            case .under, .sideBySide:
                offset = isLeft ? viewToAnimate.frame.minX : containerWidth - viewToAnimate.frame.maxX
            }
            let offsetPercent = offset / menuWidth
            let decisionPoint: CGFloat = isMenuRevealed ? 0.6 : 0.4
            if offsetPercent > decisionPoint {
                // We need to call the delegates/ change the status bar only when the menu was previous hidden
                showMenuWithOptions(shouldCallDelegate: !isMenuRevealed, shouldChangeStatusBar: !isMenuRevealed)
            } else {
                hideMenuWithOptions(shouldCallDelegate: isMenuRevealed, shouldChangeStatusBar: true)
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
        guard let sbw = UIWindow.sb, sbw.isStatusBarHidden(with: behavior) != hidden else {
            return
        }
        
        if animate && behavior != .hideOnMenu {
            UIView.animate(withDuration: 0.4, animations: {
                sbw.setStatusBar(hidden, with: behavior)
            })
        } else {
            sbw.setStatusBar(hidden, with: behavior)
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
        let statusBarFrame = UIApplication.shared.statusBarFrame
        let screenshot = UIScreen.main.snapshotView(afterScreenUpdates: false)
        screenshot.frame = statusBarFrame
        screenshot.contentMode = .top
        screenshot.clipsToBounds = true
        return screenshot
    }
    
    public override var childViewControllerForStatusBarStyle: UIViewController? {
        // Forward to the content view controller
        return contentViewController
    }
    
    public override var childViewControllerForStatusBarHidden: UIViewController? {
        return contentViewController
    }
    
    // MARK: Caching
    
    /// Caches the closure that generate the view controller with identifier.
    ///
    /// It's useful when you want to configure the caching relation without instantiating the view controller immediately.
    ///
    /// - Parameters:
    ///   - viewControllerGenerator: The closure that generate the view controller. It will only executed when needed.
    ///   - identifier: Identifier used to change content view controller
    public func cache(viewControllerGenerator: @escaping () -> UIViewController?, with identifier: String) {
        lazyCachedViewControllerGenerators[identifier] = viewControllerGenerator
    }
    
    /// Caches the view controller with identifier.
    ///
    /// - Parameters:
    ///   - viewController: the view controller to cache
    ///   - identifier: the identifier
    public func cache(viewController: UIViewController, with identifier: String) {
        lazyCachedViewControllers[identifier] = viewController
    }
    
    /// Changes the content view controller to the cached one with given `identifier`.
    ///
    /// - Parameter identifier: the identifier that associates with a cache view controller or generator.
    public func setContentViewController(with identifier: String) {
        if let viewController = lazyCachedViewControllers[identifier] {
            contentViewController = viewController
        } else if let viewController = lazyCachedViewControllerGenerators[identifier]?() {
            lazyCachedViewControllerGenerators[identifier] = nil
            lazyCachedViewControllers[identifier] = viewController
            contentViewController = viewController
        }
    }

    /// Return the identifier of current content view controller.
    ///
    /// - Returns: if not exist, returns nil.
    public func currentCacheIdentifier() -> String? {
        guard let index = lazyCachedViewControllers.values.index(of: contentViewController!) else {
            return nil
        }
        return lazyCachedViewControllers.keys[index]
    }

    /// Clears cached view controller or generators with identifier.
    ///
    /// - Parameter identifier: the identifier that associates with a cache view controller or generator.
    public func clearCache(with identifier: String) {
        lazyCachedViewControllerGenerators[identifier] = nil
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
            let factor: CGFloat = preferences.basic.direction == .left ? 1 : -1
            baseFrame.origin.x = baseFrame.origin.x * factor
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
                let factor: CGFloat = preferences.basic.direction == .left ? 1 : -1
                baseFrame.origin.x = preferences.basic.menuWidth * factor
            } else {
                baseFrame.origin.x = 0
            }
            return baseFrame
        }
    }
    
    // MARK: Container ViewController LifeCycle
    
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
