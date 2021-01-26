//
//  MainTabBarController.swift
//  BSH
//
//  Created by Emil Oldenburg on 19.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import CUU
import SwaggerClient

class MainTabBarController: CUUTabBarController {

    private static var campaign: Campaign?
    private static var image: UIImage?

    @IBInspectable var defaultIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MainTabBarController.campaign?.name
        selectedIndex = defaultIndex
    }

    public static func setCampaign(_ campaign: Campaign) {
        MainTabBarController.campaign = campaign
    }

    public static func getCampaign() -> Campaign? {
        return MainTabBarController.campaign
    }

    public static func setImage(image: UIImage) {
        MainTabBarController.image = image
    }

    public static func getImage() -> UIImage? {
        return MainTabBarController.image
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CampaignInfoViewController {
//            CampaignInfoViewController.showCampaign()
        }
    }

}
