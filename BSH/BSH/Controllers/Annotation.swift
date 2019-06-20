//
//  Annotation.swift
//  BSH
//
//  Created by Lei, Taylor on 02.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import SwaggerClient

protocol Annotation {
    var points: [Point] { get }
    var imageId: String { get set }
    var userId: String { get set }
    var campaignId: String { get set }
    var label: String { get set }
        
    func getAPIPoints() -> [SwaggerClient.Point]
}
