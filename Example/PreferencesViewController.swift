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

class PreferencesViewController: UIViewController {
    @IBOutlet weak var enablePanGesture: UISwitch!
    @IBOutlet weak var enableRubberBandEffect: UISwitch!
    @IBOutlet weak var statusBarBehaviorSegment: UISegmentedControl!
    @IBOutlet weak var menuPositionSegment: UISegmentedControl!
    @IBOutlet weak var menuDirectionSegment: UISegmentedControl!
    @IBOutlet weak var orientationSegment: UISegmentedControl!
    @IBOutlet var indicatorLabels: [UILabel]!

    var isDarkModeEnabled = false
    var themeColor = UIColor.white
    let statusBarBehaviors: [SideMenuPreferences.StatusBarBehavior] = [.none, .slide, .fade, .hideOnMenu]
    let menuPosition: [SideMenuPreferences.MenuPosition] = [.above, .under, .sideBySide]
    let menuDirections: [SideMenuPreferences.MenuDirection] = [.left, .right]
    let menuOrientation: [UIInterfaceOrientationMask] = [.portrait, .allButUpsideDown]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .under
        configureUI()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func configureUI() {
        
        if isDarkModeEnabled {
            themeColor = .mirage
            statusBarBehaviorSegment.tintColor = .lobolly
            menuPositionSegment.tintColor = .lobolly
            menuDirectionSegment.tintColor = .lobolly
            orientationSegment.tintColor = .lobolly
            for label in indicatorLabels {
                label.textColor = .white
            }
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
        menuDirectionSegment.selectedSegmentIndex = menuDirections.index(of: preferences.direction)!
        orientationSegment.selectedSegmentIndex = menuOrientation.index(of: preferences.supportedOrientations)!
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

    @IBAction func segmentControlDidChanged(_ sender: UISegmentedControl) {
        switch sender {
        case statusBarBehaviorSegment:
            SideMenuController.preferences.basic.statusBarBehavior = statusBarBehaviors[sender.selectedSegmentIndex]
        case menuPositionSegment:
            SideMenuController.preferences.basic.position = menuPosition[sender.selectedSegmentIndex]
            presentAlert()
        case menuDirectionSegment:
            SideMenuController.preferences.basic.direction = menuDirections[sender.selectedSegmentIndex]
            presentAlert()
        case orientationSegment:
            SideMenuController.preferences.basic.supportedOrientations = sender.selectedSegmentIndex == 0 ? .portrait : .allButUpsideDown
        default:
            break
        }
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Reload Side Menu", message: "Side Menu need to be reloaded after switching position", preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: "Yeah", style: .default) { (action) in
            let sideMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenu")
            UIApplication.shared.keyWindow?.rootViewController = sideMenuController
        }
        alert.addAction(confirmButton)
        present(alert, animated: true, completion: nil)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        print("View Will Transition")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDarkModeEnabled ? .lightContent : .default
    }
    
}

