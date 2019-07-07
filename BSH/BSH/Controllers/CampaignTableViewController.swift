//
//  CampaignTableViewController.swift
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

class CampaignTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var campaignId: String?
}

// MARK: - CampaignViewTableControll
class CampaignTableViewController: CUUTableViewController {
    // MARK: IBOUtlet
    @IBOutlet private weak var campaignTable: UITableView!
    
    private var campaigns: [Campaign] = []

    private static var user: User?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureRefreshControl ()
        self.campaignTable.refreshControl?.beginRefreshing()
        loadCampaigns()
        self.campaignTable.refreshControl?.endRefreshing()
    }
    
    /// Loads all existing campaigns from the database and stores them in the campaigns property
    private func loadCampaigns() {
        // we don't take the user into account yet
        // TODO: only load the campaigns of the current user
        DefaultAPI.getAllCampaigns(completion: { campaigns, error in
            guard let campaigns = campaigns else {
                // TODO: display alert when error occurs
                print(error ?? "Unspecified Error")
                return
            }
            
            self.campaigns = campaigns
            self.fillCampaignTable()
        })
    }


    func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        campaignTable.refreshControl = UIRefreshControl()
        campaignTable.refreshControl?.addTarget(self, action:
            #selector(refreshData(sender:)), for: .valueChanged)
    }

    @objc func refreshData(sender: UIRefreshControl) {
        loadCampaigns()
        self.campaignTable.refreshControl?.endRefreshing()
    }
    
    /// fills campaignTable with cells corresponding to self.campaigns, with the campaign name and description as detail
    private func fillCampaignTable() {
        if campaigns.count <= 0 {
            // TODO: show no campaigns available - how do we do this fro a UX standpoint?
            return;
        }
        
        campaignTable.reloadData()
    }
    
    // MARK: Table View Data Source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaigns.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "campaignCell", for: indexPath) as! CampaignTableViewCell
        
        // get the current cell from campaigns sorted by ids
        let campaign = campaigns.sorted(by: { $0._id < $1._id })[indexPath.row]

        cell.tag = indexPath.row
        cell.nameLabel?.text = campaign.name
        cell.descriptionLabel?.text = campaign._description
        cell.campaignId = campaign._id;
        
        if let imageURL = campaign.image,
            let url = URL(string: imageURL),
            let data = try? Data(contentsOf: url) {
            cell.imageView?.image = UIImage(data: data)
        }
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var campaign: Campaign
        campaign=campaigns[indexPath.row]
        MainTabBarController.setCampaign(campaign)
        guard let cell = campaignTable.cellForRow(at: indexPath),
            let imageView = cell.imageView,
            let image = imageView.image
            else { return }
        MainTabBarController.setImage(image: image)
        performSegue(withIdentifier: "showCampaign", sender: nil)
    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? DetailViewController, let detailToSend = sender as? SingleRepository {
//            vc.detail = detailToSend
//        }
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){

    }
}
