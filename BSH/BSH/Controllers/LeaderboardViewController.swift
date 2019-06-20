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
    var id:String = "5d0a6fe5a9edbb9d5cc29e11"
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var leaderboardTable: UITableView!
    
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
        DefaultAPI.getLeaderboard(campaignId: self.id, completion: {
            leaderboard, error in
            guard let leaderboard = leaderboard else {
                print(error ?? "whatever")
                return
            }
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

        // get the current cell from campaigns sorted by ids
        let score = leaderboard?.scores.sorted(by: { $0.score < $1.score })[indexPath.row]

        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal

        cell.positionLabel?.text = ordinalFormatter.string(from: NSNumber(value: indexPath.row + 1))

        cell.usernameLabel?.text = score?.userId

        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal



        cell.scoreLabel?.text = decimalFormatter.string(for: score?.score )


        return cell
    }
}

