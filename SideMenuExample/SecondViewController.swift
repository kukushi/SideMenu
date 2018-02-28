//
//  SecondViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 21/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second"
    }


    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sm_sideMenuController?.revealMenu()
    }
    
    @IBAction func randomButtonDidClicked(_ sender: Any) {
        textLabel.text = "\(arc4random_uniform(100))"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
