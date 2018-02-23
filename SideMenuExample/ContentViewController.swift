//
//  ViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 11/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenu

class ContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SideMenu"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sm_sideMenuController?.revealMenu()
    }
    
    @IBAction func segementControlDidChanged(_ sender: UISegmentedControl) {
        let statusBarBehaviors: [SideMenuPreferences.StatusBarBehavior] = [.none, .slide, .fade, .hideOnMenu]
        SideMenuController.preferences.basic.statusBarBehavior = statusBarBehaviors[sender.selectedSegmentIndex]
    }
    
}

