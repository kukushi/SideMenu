//
//  ThirdViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 21/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenu

class OtherExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Example"
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @IBAction func switchToProgrammaticallyExample(_ sender: Any) {
        let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentNavigation")
        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuNavigation")
        let sideMenuController = SideMenuController(contentViewController: contentViewController, menuViewController: menuViewController)
        UIApplication.shared.keyWindow?.rootViewController = sideMenuController
    }

    @IBAction func switchToIBExample(_ sender: Any) {
        let sideMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenu")
        UIApplication.shared.keyWindow?.rootViewController = sideMenuController
    }

    @IBAction func switchToHybridExample(_ sender: Any) {
        let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentNavigation")
        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuNavigation")
        guard let sideMenuController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SingleSideMenu") as? SideMenuController else {
            fatalError("Missing SingleSideMenu view controller in storyboard")
        }
        sideMenuController.contentViewController = contentViewController
        sideMenuController.menuViewController = menuViewController
        UIApplication.shared.keyWindow?.rootViewController = sideMenuController
    }
}
