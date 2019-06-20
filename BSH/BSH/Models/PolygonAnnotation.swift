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
    
    func draw(image: UIImage, view: UIImageView) {
        return
    }
    
    var points: [Point] {
        get {
            var p: [Point] = []
            // TODO:
            return p
        }
    }
    
    var imageId: String
    var userId: String
    var campaignId: String
    var label: String = ""

    init(userId: String, campaignId: String, imageId: String) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
    }

    public func getAPIPoints() -> [SwaggerClient.Point] {
        var apiPoints: [SwaggerClient.Point] = []
        
        for point in points {
            apiPoints.append(SwaggerClient.Point(x: Double(point.x), y: Double(point.y)))
        }
        
        return apiPoints
    }
}
