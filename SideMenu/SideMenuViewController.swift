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
    func sideMenuDidRecognizePanGesture(_ sideMenu: SideMenuController, recongnizer: UIPanGestureRecognizer)
    func sideMenuWillShow(_ sideMenu: SideMenuController)
    func sideMenuDidShow(_ sideMenu: SideMenuController)
    func sideMenuWillHide(_ sideMenu: SideMenuController)
    func sideMenuDidHide(_ sideMenu: SideMenuController)
}

// Provides default implementation for delegates
public extension SideMenuControllerDelegate {
    func sideMenuDidRecognizePanGesture(_ sideMenu: SideMenuController, recongnizer: UIPanGestureRecognizer) {}
    func sideMenuWillShow(_ sideMenu: SideMenuController) {}
    func sideMenuDidShow(_ sideMenu: SideMenuController) {}
    func sideMenuWillHide(_ sideMenu: SideMenuController) {}
    func sideMenuDidHide(_ sideMenu: SideMenuController) {}
}

/// Custom Segue for SideMenuController
public class SideMenuSegue: UIStoryboardSegue {
    public override func perform() {
        guard let identifier = identifier,
            let segueType = SideMenuController.StoryboardSegue(rawValue: identifier),
            let sideMenuController = source as? SideMenuController else {
                return
        }
        
        switch segueType {
        case .content:
            sideMenuController.contentViewController = destination
        case .menu:
            sideMenuController.menuViewController = destination
        }
    }
    
}


/// The SideMenuController main class
public class SideMenuController: UIViewController {
    
    public static var preferences = SideMenuPreferences()
    private var preferences: SideMenuPreferences {
        return type(of: self).preferences
    }
    
    public enum StoryboardSegue: String {
        case content = "SideMenu.Content"
        case menu = "SideMenu.Menu"
    }
    
    private var isInitiatedFromStoryboard: Bool {
        return storyboard != nil
    }
    
    @IBInspectable public var contentID: String?
    @IBInspectable public var menuID: String?

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
        }
    }
    public var menuViewController: UIViewController?

    private let menuContainerView = UIView()
    private let contentContainerView = UIView()
    private var statusBarScreenShotView: UIView?

    /// The view responsible for tapping to hide the menu
    weak private var tapView: UIView? {
        didSet {
            guard let tapView = tapView else {
                return
            }
            
            tapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            let exitPanGesture = UIPanGestureRecognizer()
            exitPanGesture.addTarget(self, action:#selector(SideMenuController.hideButtonDidClicked(_:)))
            let exitTapGesture = UITapGestureRecognizer()
            exitTapGesture.addTarget(self, action: #selector(SideMenuController.hideButtonDidClicked(_:)))
            tapView.addGestureRecognizer(exitPanGesture)
            tapView.addGestureRecognizer(exitTapGesture)
        }
    }
    
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
            performSegue(withIdentifier: contentID ?? StoryboardSegue.content.rawValue, sender: self)
            performSegue(withIdentifier: menuID ?? StoryboardSegue.menu.rawValue, sender: self)
        }
        
        contentContainerView.frame = view.bounds
        view.addSubview(contentContainerView)
        
        menuContainerView.frame = sideMenuFrame(visibility: false)
        menuViewController?.view.isHidden = true
        view.addSubview(menuContainerView)
        
        load(contentViewController, on: contentContainerView)
        load(menuViewController, on: menuContainerView)
        
        if let key = preferences.basic.defaultCacheKey {
            lazyCachedViewControllers[key] = contentViewController
        }
    }
    
    // MARK: Show/Hide Menu
    
    public func revealMenu() {
        func addTapView() {
            let tapView = UIView()
            contentContainerView.isUserInteractionEnabled = true
            contentContainerView.insertSubview(tapView, aboveSubview: contentViewController!.view)
            tapView.bounds = contentContainerView.bounds
            tapView.center = contentContainerView.center
            tapView.alpha = 0
            self.tapView = tapView
        }
        menuViewController?.view.isHidden = false
        menuViewController?.beginAppearanceTransition(true, animated: true)
        
        addTapView()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        delegate?.sideMenuWillShow(self)
        
        animateMenu(with: preferences, reveal: true, animations: {
            self.menuContainerView.frame = self.sideMenuFrame(visibility: true)
            self.tapView?.backgroundColor = .black
            self.tapView?.alpha = 0.2
        }) { (finished) in
            self.menuViewController?.endAppearanceTransition()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.delegate?.sideMenuDidShow(self)
        }
    }
    
    public func hideMenu() {
        menuViewController?.beginAppearanceTransition(true, animated: true)
        
        delegate?.sideMenuWillHide(self)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        animateMenu(with: preferences, reveal: false, animations: {
            self.menuContainerView.frame = self.sideMenuFrame(visibility: false)
            self.menuContainerView.alpha = 1.0
            self.tapView?.alpha = 0
        }) { (finished) in
            self.menuViewController?.endAppearanceTransition()
            
            self.delegate?.sideMenuDidHide(self)
            
            self.tapView?.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @objc func hideButtonDidClicked(_ tap: UITapGestureRecognizer) {
        hideMenu()
    }
    
    // MARK: Status Bar
    
    private func setStatusBar(hidden: Bool) {
        // UIKit provides `setNeedsStatusBarAppearanceUpdate` and couple of methods to animate the status bar changes.
        // The problem with this approach is it will hide the status bar and it's underlying space completely, as a result,
        // the navigation bar will go up as we don't expect.
        // So we need to manipulate the windows of status bar manually.
        
        let behavior = self.preferences.basic.statusBarBehavior
        UIWindow.sb?.set(hidden, with: behavior)
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
    
    // MARK: Cache
    
    public func cache(lazyViewController:@escaping () -> UIViewController?, with identifier: String) {
        lazyCachedViewControllerClosures[identifier] = lazyViewController
    }
    
    public func cache(viewController: UIViewController, with identifier: String) {
        lazyCachedViewControllers[identifier] = viewController
    }
    
    public func switchToViewController(with identifier: String) {
        if let viewController = lazyCachedViewControllers[identifier] {
            contentViewController = viewController
        } else if let viewController = lazyCachedViewControllerClosures[identifier]?() {
            lazyCachedViewControllerClosures[identifier] = nil
            lazyCachedViewControllers[identifier] = viewController
            contentViewController = viewController
        }
    }
    
    // MARK: - Helper Methods
    
    private func animateMenu(with preferences: SideMenuPreferences,
                     reveal: Bool,
                     animations: @escaping () -> Void,
                     completion: ((Bool) -> Void)? = nil) {
        let shouldAnimateStatusBarChange = preferences.basic.statusBarBehavior != .hideOnMenu
        if !shouldAnimateStatusBarChange && reveal {
            setStatusBar(hidden: reveal)
        }
        let duration = reveal ? preferences.animation.revealDuration : preferences.animation.hideDuration
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: preferences.animation.usingSpringDamping,
                       initialSpringVelocity: preferences.animation.initialSpringVelocity,
                       options: preferences.animation.options,
        animations: {
            if shouldAnimateStatusBarChange {
                self.setStatusBar(hidden: reveal)
            }
            animations()
        }) { (finished) in
            if !shouldAnimateStatusBarChange && !reveal {
                self.setStatusBar(hidden: reveal)
            }
            completion?(finished)
        }
    }
    
    private func sideMenuFrame(visibility: Bool) -> CGRect {
        var baseFrame = view.frame
        if visibility {
            baseFrame.origin.x = preferences.basic.menuWidth - baseFrame.width
        } else {
            baseFrame.origin.x = -baseFrame.width
        }
        return baseFrame
    }
    
    // MARK: Container ViewController Lifecyle
    
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
