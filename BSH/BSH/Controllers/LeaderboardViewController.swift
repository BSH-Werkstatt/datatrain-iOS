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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}

// MARK: - LeaderboardViewController
class LeaderboardViewController: CUUTableViewController {

    var leaderboard: Leaderboard
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var leaderboardTable: UITableView!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getLeaderboard()
    }

    func getLeaderboard(id:String = "5d0a6fe5a9edbb9d5cc29e11"){
        DefaultAPI.getLeaderboard(campaignId: id, completion: {
            leaderboard, error in
            guard let leaderboard = leaderboard else {
                print(error ?? "whatever")
                return
            }
            self.leaderboard = leaderboard
        })
    }

    // MARK: Table View Data Source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.scores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardCellController

        // get the current cell from campaigns sorted by ids
        let score = leaderboard.scores.sorted(by: { $0.score < $1.score })[indexPath.row]

        let formater = NumberFormatter()
        formater.numberStyle = .ordinal

        cell.titleLabel?.text = formater.string(from: NSNumber(value: indexPath.row))
        cell.descriptionLabel?.text = score.userId


        return cell
    }
}

