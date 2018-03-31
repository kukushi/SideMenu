//
//  SecondViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 21/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit

class WorkWithOtherViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Work With Other"
    }
    
    @IBAction func pushViewControllerButtonDiidClicked(_ sender: Any) {
        let viewController = PushedViewController()
        viewController.view.backgroundColor = .white
        navigationController?.pushViewController(viewController, animated: true)
    }
    

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }
    
    @IBAction func randomButtonDidClicked(_ sender: Any) {
        textLabel.text = "\(arc4random_uniform(100))"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}


class PushedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        printSideMenu(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        printSideMenu(#function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        printSideMenu(#function)
    }
    
    private func printSideMenu(_ function: String) {
        let representation = sideMenuController != nil ? String(describing: sideMenuController!) : "nil"
        print("In `\(function)`, sideMenuControlelr is: \(representation)")
        
        if sideMenuController == nil {
            let representation2 = navigationController != nil ? String(describing: navigationController!) : "nil"
            print("    - And navigationController is: \(representation2)")
        }
    }
}
