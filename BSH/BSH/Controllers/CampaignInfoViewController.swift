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
import SwaggerClient

// MARK: - CampaignTableControll
class CampaignInfoViewController: CUUViewController {
    private static var campaign: Campaign?
    
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
        if let campaign = CampaignInfoViewController.campaign {
            campaignName.text = campaign.name
        }
    }
    
    public static func setCampaign(_ campaign: Campaign) {
        CampaignInfoViewController.campaign = campaign
    }
    
    public static func getCampaign() -> Campaign? {
        return CampaignInfoViewController.campaign
    }
}
