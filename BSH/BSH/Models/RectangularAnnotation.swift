//
//  RectangularAnnotation.swift
//  BSH
//
//  Created by Lei, Taylor on 02.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import SwaggerClient

class RectangularAnnotation : Annotation {
    var topLeft: Point
    var bottomRight: Point
    
    var points: [Point] {
        get {
            var p: [Point] = []
            p.append(Point(x: topLeft.x, y: topLeft.y))
            p.append(Point(x: bottomRight.x, y: topLeft.y))
            p.append(Point(x: bottomRight.x, y: bottomRight.y))
            p.append(Point(x: topLeft.x, y: bottomRight.y))
            return p
        }
    }
    var imageId: String
    var userId: String
    var campaignId: String
    var label: String = ""
    
    init(topLeft: Point, bottomRight: Point, userId: String, campaignId: String, imageId: String) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        
        checkAndFixCorners()
    }
    
    public func draw(image: UIImage, view: UIImageView) {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        image.draw(at: CGPoint.zero)
        
        let rectangle = CGRect(x: points[0].x, y: points[0].y, width: points[2].x - points[0].x, height: points[2].y - points[0].y)
        let fillColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(0.5)).cgColor
        let strokeColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(1.0)).cgColor
        
        context.setStrokeColor(strokeColor)
        context.stroke(rectangle, width: image.size.width / CGFloat(100.0))
        context.setFillColor(fillColor)
        context.fill(rectangle)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = newImage
    }
    
    public func setTopLeft(point: Point) {
        self.topLeft = point
        checkAndFixCorners()
    }
    
    public func setBottomRight(point: Point) {
        self.bottomRight = point
        checkAndFixCorners()
    }
    
    private func checkAndFixCorners() {
        let maxX = topLeft.x > bottomRight.x ? topLeft.x : bottomRight.x
        let minX = topLeft.x < bottomRight.x ? topLeft.x : bottomRight.x
        let maxY = topLeft.y > bottomRight.y ? topLeft.y : bottomRight.y
        let minY = topLeft.y < bottomRight.y ? topLeft.y : bottomRight.y
        
        topLeft = Point(x: minX, y: minY)
        bottomRight = Point(x: maxX, y: maxY)
    }
    
    public func getAPIPoints() -> [SwaggerClient.Point] {
        var apiPoints: [SwaggerClient.Point] = []
        
        for point in points {
            apiPoints.append(SwaggerClient.Point(x: Double(point.x), y: Double(point.y)))
        }
        
        return apiPoints
    }
}
