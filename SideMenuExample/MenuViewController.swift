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
    var isDarkModeEnabled = false
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var selectionTableViewHeader: UILabel!
    
    @IBOutlet weak var selectionMenuTrailingConstraint: NSLayoutConstraint!
    private var themeColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .below
        configureView()

        guard let theSideMenuController = sm_sideMenuController else {
            return
        }
        sideMenuController = theSideMenuController
        
        sideMenuController.cache(viewControllerClosure: { self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") }, with: "1")
        sideMenuController.cache(viewControllerClosure: { self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController") }, with: "2")
        sideMenuController.delegate = self
    }
    
    private func configureView() {
        if isDarkModeEnabled {
            selectionMenuTrailingConstraint.constant = SideMenuController.preferences.basic.menuWidth - view.frame.width
            themeColor = UIColor(red:0.03, green:0.04, blue:0.07, alpha:1.00)
            selectionTableViewHeader.textColor = .white
        } else {
            selectionMenuTrailingConstraint.constant = 0
            themeColor = UIColor(red:0.98, green:0.97, blue:0.96, alpha:1.00)
        }
        view.backgroundColor = themeColor
        tableView.backgroundColor = themeColor
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelectionCell
        cell.contentView.backgroundColor = themeColor
        let row = indexPath.row
        if row == 0 {
            cell.titleLabel?.text = "First ViewController"
        } else if row == 1 {
            cell.titleLabel?.text = "Second ViewController"
        } else if row == 2 {
            cell.titleLabel?.text = "Third ViewController"
        }
        cell.titleLabel?.textColor = isDarkModeEnabled ? .white : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        sideMenuController.setContentViewController(with: "\(row)")
        sideMenuController.hideMenu()
        
        print("ViewCOntroller Cache Identifier: " + sideMenuController.currentCacheIdentifier()!)
    }
}

class SelectionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

