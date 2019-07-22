//
//  LeaderboardViewController.swift
//  BSH
//
//  Created by Susanne Winkler on 29.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit
import SwaggerClient
import CUU
import NotificationBannerSwift

class LeaderboardCellController: UITableViewCell {
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}

// MARK: - LeaderboardViewController
class LeaderboardViewController: CUUTableViewController {

    var leaderboard: Leaderboard?
    var campaign: Campaign?
    var scores: [LeaderboardScore] = []
    var myRank: Int {
        if scores.count == 0 {
            getLeaderboard()
        }
        guard let userId = UserDefaults.standard.string(forKey: "user-id") else {
            let banner = NotificationBanner(title: "Invalid user id", subtitle: "Please check if you are logged in correctly", style: .success)
            banner.show()
            return -1
        }
        if scores.count <= 0 {
            return -1
        }
        for i in 0...scores.count - 1 {
            if scores[i].userId == userId {
                return i
            }
        }
        return -1
    }
    
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var leaderboardTable: UITableView!
    @IBOutlet weak var campaingLabel: UILabel!

    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getLeaderboard()
        configureRefreshControl()
        //refreshing controls
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLeaderboard()
        //CUU Seed for tracking leaderboard checks
        CUU.seed(name: "Leaderboard checked")
    }

    func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        leaderboardTable.refreshControl = UIRefreshControl()
        leaderboardTable.refreshControl?.addTarget(self, action:
            #selector(refreshData(sender:)), for: .valueChanged)
    }

    @objc func refreshData(sender: UIRefreshControl) {

        getLeaderboard()
        DispatchQueue.main.async {
            self.leaderboardTable.refreshControl?.endRefreshing()
        }
    }

    func getLeaderboard() {

        guard let campaign = MainTabBarController.getCampaign() else {
            self.campaingLabel?.text = "No campaign has been chosen. Please select a campaign in the campaigns tab!"
            return
        }
        DefaultAPI.getLeaderboard(campaignId: campaign._id, completion: {
            leaderboard, error in
            guard let leaderboard = leaderboard else {
                print(error ?? "whatever")
                self.campaingLabel?.text = "There is no data for this leaderboard yet. \nStart annotattong or uploading now!"
                return
            }
            self.campaingLabel?.text = ""
            self.leaderboard = leaderboard
            self.scores = leaderboard.scores.sorted(by: { $0.score > $1.score })
            self.leaderboardTable.reloadData()
        })
    }

    // MARK: Table View Data Source methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0, myRank > 10 {
            return "People around your ranking"
        }
        return "All users"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return myRank <= 10 ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myRank <= 10 || leaderboard?.scores.count ?? 0 < 10 {
            return leaderboard?.scores.count ?? 0
        }
        if section == 0 {
            return 7
        } else {
            return leaderboard?.scores.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardCellController

        let index: Int
        if indexPath.section == 0 && myRank > 10 {
            if myRank + 3 > scores.count - 1 {
                let shift = scores.count - 1 - myRank
                index = indexPath.row + myRank - shift
            } else {
                index = indexPath.row + myRank - 3
            }
        } else {
            index = indexPath.row
        }
        // get the current cell from campaigns sorted by score
        let score = scores[index]
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        cell.positionLabel?.text = ordinalFormatter.string(from: NSNumber(value: index + 1))
        cell.usernameLabel?.text = score.name
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        cell.scoreLabel?.text = decimalFormatter.string(for: score.score )
        return cell
    }
}

