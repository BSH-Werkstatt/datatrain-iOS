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
import CUU

// MARK: - LeaderboardViewController
class LeaderboardViewController: CUUTableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var leaderboardTable: UITableView!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

