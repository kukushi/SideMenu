//
//  MenuViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 11/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenu

class MenuViewController: UIViewController {
    weak var sideMenuController: SideMenuController!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let theSideMenuController = sm_sideMenuController else {
            return
        }
        sideMenuController = theSideMenuController
        
        sideMenuController.cache(viewControllerClosure: { self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") }, with: "1")
        sideMenuController.cache(viewControllerClosure: { self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController") }, with: "2")
        sideMenuController.delegate = self
    }
}

extension MenuViewController: SideMenuControllerDelegate {
    func sideMenuWillHide(_ sideMenu: SideMenuController) {
        print("Side Menu Will Hide")
    }
    
    func sideMenuDidHide(_ sideMenu: SideMenuController) {
        print("Side Menu Did Hide.")
    }
    
    func sideMenuWillShow(_ sideMenu: SideMenuController) {
        print("Side Menu Will Show.")
    }
    
    func sideMenuDidShow(_ sideMenu: SideMenuController) {
        print("Side Mneu Did Show.")
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = indexPath.row
        if row == 0 {
            cell.textLabel?.text = "1st ViewController"
        } else if row == 1 {
            cell.textLabel?.text = "2nd ViewController"
        } else if row == 2 {
            cell.textLabel?.text = "3rd ViewController"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        sideMenuController.setContentViewController(with: "\(row)")
        sideMenuController.hideMenu()
        
        print("ViewCOntroller Cache Identifier: " + sideMenuController.currentCacheIdentifier()!)
    }
}


