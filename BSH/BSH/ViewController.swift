//
//  ViewController.swift
//  BSH
//
//  Created by Emil Oldenburg on 07.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//
// MARK: Imports
import UIKit
import CUU

// MARK: - ViewController
class ViewController: CUUViewController {
    // MARK: IBOutlets
    @IBOutlet private weak var outputLabel: UILabel!
    
    // MARK: IBActions
    @IBAction private func uploadImage() {
        if let pictureAmountString = outputLabel.text,
            let pictureAmount = Int(pictureAmountString) {
            outputLabel.text = String(pictureAmount + 1)
            // Feature Crumb Name: "<Upload Picture>"
            CUU.seed(name: "Upload Picture")
        }
    }
    

    
    @IBAction private func addLabel() {
        print("Label added")
        // not implemented labeling yet
        // Feature Crumb Name: "<adding Label>"
        CUU.seed(name: "adding Label")
    }
    
    
    
    @IBAction private func leaderboardPressed() {
        print("Leaderboard Button pressed")
        // Feature Crumb Name: "<Go to Leaderboard>"
        CUU.seed(name: "Go to Leaderboard")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
}

