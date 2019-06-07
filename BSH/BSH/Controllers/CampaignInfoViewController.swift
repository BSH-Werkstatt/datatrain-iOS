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
    @IBOutlet private weak var campaignName: UILabel!
    @IBOutlet private weak var campaignInfoText: UITextView!
    @IBOutlet weak var campaignImageView: UIImageView!
    
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
            campaignInfoText.text = campaign._description
            
            // TODO: do not load image twice, instead pass it from the campaign table view
            if let imageURL = campaign.image,
                let url = URL(string: imageURL),
                let data = try? Data(contentsOf: url) {
                self.campaignImageView.image = UIImage(data: data)
            }
        }
    }
    
    public static func setCampaign(_ campaign: Campaign) {
        CampaignInfoViewController.campaign = campaign
    }
    
    public static func getCampaign() -> Campaign? {
        return CampaignInfoViewController.campaign
    }
    
    @IBAction func unwindToCampainInfoView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
