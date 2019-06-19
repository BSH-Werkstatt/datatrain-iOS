//
//  MainTabBarController.swift
//  BSH
//
//  Created by Emil Oldenburg on 19.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }

}
