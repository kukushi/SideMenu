//
//  ViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 11/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenu

extension UIColor {
    static var mirage: UIColor {
        return UIColor(red:0.08, green:0.11, blue:0.19, alpha:1.00)
    }
    
    static var lobolly: UIColor {
        return UIColor(red:0.75, green:0.78, blue:0.81, alpha:1.00)
    }
}

class ContentViewController: UIViewController {
    @IBOutlet weak var enablePanGesture: UISwitch!
    @IBOutlet weak var enableRubberBandEffect: UISwitch!
    @IBOutlet weak var statusBarBehaviorSegment: UISegmentedControl!
    @IBOutlet weak var menuPositionSegment: UISegmentedControl!
    @IBOutlet var indicatorLabels: [UILabel]!
    @IBOutlet weak var rebuildButton: UIButton!
    
    var isDarkModeEnabled = false
    var themeColor = UIColor.white
    let statusBarBehaviors: [SideMenuPreferences.StatusBarBehavior] = [.none, .slide, .fade, .hideOnMenu]
    let menuPosition: [SideMenuPreferences.MenuPosition] = [.above, .below, .sideBySide]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SideMenu"
        
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .below
        configureUI()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func configureUI() {
        
        if isDarkModeEnabled {
            themeColor = .mirage
            statusBarBehaviorSegment.tintColor = .lobolly
            menuPositionSegment.tintColor = .lobolly
            for label in indicatorLabels {
                label.textColor = .white
            }
            rebuildButton.tintColor = .lobolly
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = .lobolly
            navigationController?.navigationBar.barTintColor = .mirage
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        } else {
            themeColor = .white
        }
        view.backgroundColor = themeColor
        
        
        let preferences = SideMenuController.preferences.basic
        statusBarBehaviorSegment.selectedSegmentIndex = statusBarBehaviors.index(of: preferences.statusBarBehavior)!
        menuPositionSegment.selectedSegmentIndex = menuPosition.index(of: preferences.position)!
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sm_sideMenuController?.revealMenu()
    }
    
    @IBAction func segementControlDidChanged(_ sender: UISegmentedControl) {
        switch sender {
        case statusBarBehaviorSegment:
            let statusBarBehaviors: [SideMenuPreferences.StatusBarBehavior] = [.none, .slide, .fade, .hideOnMenu]
            SideMenuController.preferences.basic.statusBarBehavior = statusBarBehaviors[sender.selectedSegmentIndex]
        case menuPositionSegment:
            
            SideMenuController.preferences.basic.position = menuPosition[sender.selectedSegmentIndex]
        default:
            break
        }
    }
    
    @IBAction func switchDidClicked(_ sender: UISwitch) {
        switch sender {
        case enablePanGesture:
            SideMenuController.preferences.basic.enablePanGesture = sender.isOn
        case enableRubberBandEffect:
            SideMenuController.preferences.basic.enableRubberEffectWhenPanning = sender.isOn
        default:
            break
        }
    }
    
    @IBAction func rebulidSideMenuController(_ sender: Any) {
        let sideMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenu")
        UIApplication.shared.keyWindow?.rootViewController = sideMenuController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDarkModeEnabled ? .lightContent : .default
    }
    
}

