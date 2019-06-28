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

class LeaderboardCellController: UITableViewCell {
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}

// MARK: - LeaderboardViewController
class LeaderboardViewController: CUUTableViewController {

    var leaderboard: Leaderboard?
    var campaign:Campaign?
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var leaderboardTable: UITableView!
    @IBOutlet weak var campaingLabel: UILabel!

    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        getLeaderboard()
        //refreshing controls

    }

    func configureRefreshControl () {
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

    func getLeaderboard(){

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
            self.campaingLabel?.text = campaign.name
            self.leaderboard = leaderboard
            self.leaderboardTable.reloadData()
        })
    }

    // MARK: Table View Data Source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard?.scores.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardCellController

        // get the current cell from campaigns sorted by score
        let score = leaderboard?.scores.sorted(by: { $0.score > $1.score })[indexPath.row]

        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal

        cell.positionLabel?.text = ordinalFormatter.string(from: NSNumber(value: indexPath.row + 1))

        cell.usernameLabel?.text = score?.email

        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal



        cell.scoreLabel?.text = decimalFormatter.string(for: score?.score )


        return cell
    }
}

