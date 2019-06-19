//
//  BshCustomButton.swift
//  BSH
//
//  Created by Emil Oldenburg on 09.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//


import Foundation
import UIKit

class BshCustomButton : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5.0
//        self.layer.borderColor = UIColor.red.cgColor
//        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor(red: 0.973, green: 0.62, blue: 0.208, alpha: 1) // #f89e35
        self.tintColor = UIColor.white
    }
}
