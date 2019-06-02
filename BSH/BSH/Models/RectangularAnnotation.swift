//
//  RectangularAnnotation.swift
//  BSH
//
//  Created by Lei, Taylor on 02.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation

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
        
        points = []
        points.append(Point(x: topLeft.x, y: topLeft.y))
        points.append(Point(x: bottomRight.x, y: topLeft.y))
        points.append(Point(x: bottomRight.x, y: bottomRight.y))
        points.append(Point(x: topLeft.x, y: bottomRight.y))        
    }
    
    func draw() {
        
    }
}
