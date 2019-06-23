//
//  ProfileController.swift
//  BSH
//
//  Created by Emil Oldenburg on 20.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit
import CUU
import SwaggerClient

// MARK: - LeaderboardViewController
class ProfileViewController: CUUTableViewController {

    var user: User?
    // MARK: IBOutlets


    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet var profileTableView: UITableView!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl ()
        getProfile()
    }

    func getProfile() {
        guard let email = UserDefaults.standard.string(forKey: "user-email") else {
            return
        }
        DefaultAPI.getUserByEmail(email: email, completion: {
            user, error in
            guard let user = user else {
                print (error ?? "whatever")
                return
            }
            self.user = user
            self.emailLabel.text = user.email
            self.idLabel.text = user._id
        })
    }

    //refreshing controls

    func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        profileTableView.refreshControl = UIRefreshControl()
        profileTableView.refreshControl?.addTarget(self, action:
            #selector(refreshData(sender:)), for: .valueChanged)
    }

    @objc func refreshData(sender: UIRefreshControl) {
        getProfile()
        DispatchQueue.main.async {
            self.profileTableView.refreshControl?.endRefreshing()
        }
    }

    @IBAction func dismissProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }

    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "loggedIn")
        Switcher.updateRootVC()
    }
    
}
