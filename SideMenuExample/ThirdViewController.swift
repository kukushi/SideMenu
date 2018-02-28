//
//  ThirdViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 21/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Third"
    }


    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sm_sideMenuController?.revealMenu()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
