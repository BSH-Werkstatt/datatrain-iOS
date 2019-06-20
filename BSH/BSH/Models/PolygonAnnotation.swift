//
//  PolygonAnnotation.swift
//  BSH
//
//  Created by Baris Sen on 6/20/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import SwaggerClient

class PolygonAnnotation : Annotation {
    
    var points: [Point]
    
    var imageId: String
    var userId: String
    var campaignId: String
    var label: String = ""

    init(userId: String, campaignId: String, imageId: String, points: [Point]) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
        self.points = points
    }

    public func getAPIPoints() -> [SwaggerClient.Point] {
        var apiPoints: [SwaggerClient.Point] = []
        
        for point in points {
            apiPoints.append(SwaggerClient.Point(x: Double(point.x), y: Double(point.y)))
        }
        
        return apiPoints
    }
}
