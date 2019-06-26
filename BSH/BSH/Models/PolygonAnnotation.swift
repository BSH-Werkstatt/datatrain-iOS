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

    var points: [CGPoint] = []
    var completed: Bool = false
    var label: String = ""
    var imageId: String
    var userId: String
    var campaignId: String
    var temporaryPoint: CGPoint?
    var annotationView: AnnotationView?

    init(userId: String, campaignId: String, imageId: String) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
    }
    
    func addPoint(point: CGPoint) {
        points.append(point)
    }

    public func getAPIPoints() -> [SwaggerClient.Point] {
        var apiPoints: [SwaggerClient.Point] = []
        let rescaledPoints = annotationView!.getPoints()
        for point in rescaledPoints {
            apiPoints.append(SwaggerClient.Point(x: Double(point.x), y: Double(point.y)))
        }
        return apiPoints
    }
}
