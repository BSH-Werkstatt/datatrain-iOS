//
//  CampaignInfoViewController.swift
//  BSH
//
//  Created by Susanne Winkler on 29.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit
import CUU

// MARK: - CampaignTableControll
class CampaignInfoViewController: CUUViewController {
    // !! Why is there a connection with the Table??
   
    // MARK: IBOutlets
    @IBOutlet weak var campaignName: UILabel!
    @IBOutlet weak var campaignInfoScrollView: UIScrollView!
    
    // MARK: IBActions
    @IBAction func startCampaignButton() {
        // what to do when Campaign starts
        // select which campaign + and Segue!
    }
    
    @IBAction func toLeaderboardButton() {
        // Go to Campaign Leaderboard
    }
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
