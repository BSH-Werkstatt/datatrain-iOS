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

class Annotation {
    var points: [CGPoint] = []
    var completed: Bool = false
    var label: String = ""
    var imageId: String
    var userId: String
    var campaignId: String
    var temporaryPoint: CGPoint?
    var annotationView: AnnotationView?
    
    var startPoint: CGPoint? {
        return points.first
    }
    var endPoint: CGPoint? {
        return temporaryPoint ?? points.last
    }
    
    func scale(_ value: CGFloat) -> CGFloat {
        guard let annotationView = annotationView else {
            return value
        }
        return annotationView.scale(value)
    }

    init(userId: String, campaignId: String, imageId: String) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
    }
    
    func addPoint(point: CGPoint) {
        points.append(point)
    }
    
    func getPointRect(point: CGPoint) -> CGRect? {
        if let startPoint = startPoint, point == startPoint {
            return CGRect(x: startPoint.x - scale(10), y: startPoint.y - scale(10), width: scale(20.0), height: scale(20.0))
        }
        if let endPoint = endPoint, point == endPoint {
            return CGRect(x: endPoint.x - scale(10), y: endPoint.y - scale(10), width: scale(20.0), height: scale(20.0))
        }
        for p in points {
            if p == point {
                return CGRect(x: p.x - scale(2.5), y: p.y - scale(2.5), width: scale(5.0), height: scale(5.0))
            }
        }
        return nil
    }
    
    func getLargePointRect(point: CGPoint) -> CGRect? {
        if let startPoint = startPoint, point == startPoint {
            return CGRect(x: startPoint.x - 17.5, y: startPoint.y - 17.5, width: 35.0, height: 35.0)
        }
        if let endPoint = endPoint, point == endPoint {
            return CGRect(x: endPoint.x - 17.5, y: endPoint.y - 17.5, width: 35.0, height: 35.0)
        }
        for p in points {
            if p == point {
                return CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5.0, height: 5.0)
            }
        }
        return nil
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
