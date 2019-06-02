//
//  RectangularAnnotation.swift
//  BSH
//
//  Created by Lei, Taylor on 02.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit

class RectangularAnnotation : Annotation {
    var points: [Point]
    var imageId: Int
    var userId: Int
    var campaignId: Int
    var label: String = ""
    
    init(topLeft: Point, bottomRight: Point, userId: Int, campaignId: Int, imageId: Int) {
        self.userId = userId
        self.campaignId = campaignId
        self.imageId = imageId
        
        // TODO: error handling: is topLeft really the top left corner?
        points = []
        points.append(Point(x: topLeft.x, y: topLeft.y))
        points.append(Point(x: bottomRight.x, y: topLeft.y))
        points.append(Point(x: bottomRight.x, y: bottomRight.y))
        points.append(Point(x: topLeft.x, y: bottomRight.y))
    }
    
    func draw(image: UIImage, view: UIImageView) {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(at: CGPoint.zero)
        
        let rectangle = CGRect(x: points[0].x, y: points[0].y, width: points[2].x - points[0].x, height: points[2].y - points[0].y)
        
        UIColor.black.setFill()
        UIRectFill(rectangle)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = newImage
    }
}
