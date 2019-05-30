//
//  CampaignViewController.swift
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

// MARK: - CampaignViewTableControll
class CampaignViewController: CUUTableViewController {
    // MARK: IBOUtlet
    @IBOutlet private weak var campaignTable: UITableView!
    
    private var campaigns: [Campaign] = []
    private var activeCampaign: Campaign?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadCampaigns()
    }
    
    /// Gets the currently active campaign, which was selected in the CampaignView
    public func getActiveCampaign() -> Campaign? {
        return activeCampaign
    }
    
    /// Loads all existing campaigns from the database and stores them in the campaigns property
    private func loadCampaigns() {
        // we don't take the user into account yet
        DefaultAPI.getAllCampaigns(completion: { campaigns, error in
            guard let campaigns = campaigns else {
                print(error ?? "Unspecified Error")
                return
            }
            
            self.campaigns = campaigns
        })
    }
}
