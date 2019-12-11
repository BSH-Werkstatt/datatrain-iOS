//
//  Constants.swift
//  BSH
//
//  Created by BSH iMac on 02/12/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit

struct LoginConstants {
    static let LOGIN_TITLE    = "Login"
    static let ALERT_TITLE    = "Login Error"
    static let USERNAME_EMPTY = "Please enter a username"
    static let PASSWORD_EMPTY = "Please enter a password"
    static let LOGIN_FAILURE  = "Login Failed"
    static let LOGIN_SUCCESS  = "Login Successful"
    static let BASE_URL       = "https://issuetracking.bsh-sdd.com/rest/api/2"
    static let LOGIN_API      = String(format: "%@/myself", BASE_URL)
}
