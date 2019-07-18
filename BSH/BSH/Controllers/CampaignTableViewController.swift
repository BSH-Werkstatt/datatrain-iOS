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
import OnboardKit

class CampaignTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var campaignImage: UIImageView!
    var campaignId: String?
    
}

// MARK: - CampaignViewTableControll
class CampaignTableViewController: CUUTableViewController {
    // MARK: IBOUtlet
    @IBOutlet private weak var campaignTable: UITableView!
    
    private var campaigns: [Campaign] = []

    private static var user: User?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let launchedBeforeKey = "launchedBefore"
    
    //Onboarding Screen
    let pageOne = OnboardPage(title: "Welcome to the DataTr/ai/n",
                              imageName: "party",
                              description: "We will help you with how to annotate.")
    let pageTwo = OnboardPage(title: "Pick a campaign",
                              imageName: "pickCampaign",
                              description: "First choose a campaign you were invited to participate in.")
    let pageThree = OnboardPage(title: "Campaign info",
                                imageName: "Buttons",
                                description: "After you read the description, you can upload your own image or use random images from the campaign.")
    let pageFour = OnboardPage(title: "How to annotate",
                               imageName: "Buttons",
                               description: "Draw a line around  the item you want to annotate. Remember to complete a circle!")
    let pageFive = OnboardPage(title: "Select a label",
                               imageName: "Buttons",
                               description: "Pick a label from the list. If you can't find the suitable label, you can create a new one")
    let pageSix = OnboardPage(title: "Repeat or Submit",
                              imageName: "submit",
                              description: "Either start drawing a new line or submit your annotations.",
                              advanceButtonTitle: "Done")
    
    let appearance = OnboardViewController.AppearanceConfiguration(imageContentMode: .scaleAspectFit)
    
    
    lazy var onboardingViewController = OnboardViewController(pageItems: [pageOne, pageTwo,pageThree, pageFour, pageFive, pageSix], appearanceConfiguration: appearance)
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingViewController.presentFrom(self, animated: true)

        // Do any additional setup after loading the view.
        configureRefreshControl ()
        self.campaignTable.refreshControl?.beginRefreshing()
        loadCampaigns()
        self.campaignTable.refreshControl?.endRefreshing()
        
        //activityIndicator shown
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
        campaignTable.backgroundView = activityIndicator
        activityIndicator.startAnimating()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let launchedBefore = UserDefaults.standard.bool(forKey: launchedBeforeKey)
        
        if !launchedBefore {
            // First launch 
            onboardingViewController.presentFrom(self, animated: true)
            UserDefaults.standard.set(true, forKey: launchedBeforeKey)
        }
        
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
            
            //activityIndicator hidden, when data is loaded
            self.activityIndicator.stopAnimating()
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
        
        // get campaign image
        if let url = URL(string: campaign.image),
            let data = try? Data(contentsOf: url) {
            cell.campaignImage?.image = UIImage(data: data)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var campaign: Campaign
        campaign = campaigns[indexPath.row]
        MainTabBarController.setCampaign(campaign)
        guard let cell = campaignTable.cellForRow(at: indexPath) as! CampaignTableViewCell?,
            let imageView = cell.campaignImage,
            let image = imageView.image
            else { return }
        MainTabBarController.setImage(image: image)
        performSegue(withIdentifier: "showCampaign", sender: nil)
       
        //CUU Seeds 
        CUU.seed(name: "Campaign List clicked")
    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? DetailViewController, let detailToSend = sender as? SingleRepository {
//            vc.detail = detailToSend
//        }
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){

    }
}
