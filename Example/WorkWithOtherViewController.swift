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

        title = "Scroll View and Others"
    }

    @IBAction func pushViewControllerButtonDidClicked(_ sender: Any) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "PushedViewController") else {
            return
        }
        viewController.view.backgroundColor = .white
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func presentViewControllerButtonClicked(_ sender: UIButton) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "PushedViewController") else {
            return
        }
        viewController.view.backgroundColor = .white
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(dismissViewController))
        present(navigationController, animated: true, completion: nil)
    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

}

class PushedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var items = [String](repeating: "Cell", count: 100)

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
        if let sideMenuController = sideMenuController {
            print("In `\(function)`, sideMenuControlLer is: \(sideMenuController)")
        }

        if navigationController == navigationController {
            print("    - And navigationController is: \(String(describing: navigationController))")
        }
    }
}

extension PushedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row]) \(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
