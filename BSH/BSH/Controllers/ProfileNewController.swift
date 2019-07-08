//
//  ProfileNewController.swift
//  BSH
//
//  Created by Susanne Winkler on 08.07.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation

import UIKit
import CUU
import SwaggerClient

// MARK: - LeaderboardViewController
class ProfileNewController: CUUViewController {
    
    var user: User?
    // MARK: IBOutlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buildVersionLabel: UILabel!
    
// MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    //configureRefreshControl () not possible in UIView
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
            self.nameLabel.text = user.name
            self.buildVersionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No build number found"
        })
    }
    
    //refreshing controls
    
    /*func configureRefreshControl () {
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
 */
    
    @IBAction func dismissProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "loggedIn")
        Switcher.updateRootVC()
    }
    
}
