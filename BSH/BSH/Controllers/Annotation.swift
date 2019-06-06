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
    var imageId: Int { get set }
    var userId: Int { get set }
    var campaignId: Int { get set }
    var label: String { get set }
    
    func draw(image: UIImage, view: UIImageView)
    
    func getAPIPoints() -> [SwaggerClient.Point]
}
