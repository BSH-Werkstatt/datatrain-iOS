//
//  AnnotationView.swift
//  BSH
//
//  Created by Baris Sen on 6/20/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import UIKit

class AnnotationView: UIView {
    
    private var pointArrays: [[CGPoint]] = [[]]
    private var completed: [Bool] = [false]
    private var offsetX: CGFloat?
    private var offsetY: CGFloat?
    private var imageSizeX: CGFloat?
    private var imageSizeY: CGFloat?
    
    private var fillColor: UIColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(0.5))
    
    private var strokeColor: UIColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(1.0))

    override func draw(_ rect: CGRect) {
        if (pointArrays.count > 0) {
            let path = UIBezierPath()
            path.lineWidth = 3.0
            for index in 0...pointArrays.count - 1 {
                if pointArrays[index].count == 1 {
                    // There is only one point to draw
                    path.move(to: pointArrays[index][0])
                    strokeColor.setStroke()
                    path.stroke()
                } else if pointArrays[index].count >= 1 && completed[index] {
                    // There is a compeleted path
                    path.move(to: pointArrays[index][0])
                    for i in 1...pointArrays[index].count - 1 {
                        path.addLine(to: pointArrays[index][i])
                    }
                    path.close()
                    strokeColor.setStroke()
                    fillColor.setFill()
                    path.fill()
                    path.stroke()
                } else if pointArrays[index].count >= 1 && !completed[index] {
                    // There is an uncompleted path
                    path.move(to: pointArrays[index][0])
                    for i in 1...pointArrays[index].count - 1 {
                        path.addLine(to: pointArrays[index][i])
                    }
                    strokeColor.setStroke()
                    path.stroke()
                }
            }
        }
    }
    
    func setOffsetVariables(offsetX: CGFloat, offsetY: CGFloat) {
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
    
    func setImageSize(imageSizeX: CGFloat, imageSizeY: CGFloat) {
        self.imageSizeX = imageSizeX
        self.imageSizeY = imageSizeY
    }
    
    func add(point: CGPoint, to annotation: Int) {
        // TODO: Index check
        guard let offsetX = offsetX, let offsetY = offsetY,
            let imageSizeX = imageSizeX, let imageSizeY = imageSizeY else {
            return
        }
        
        if (point.x > offsetX && point.y > offsetY &&
            point.x < offsetX + imageSizeX && point.y < offsetY + imageSizeY) {
            pointArrays[annotation].append(point)
            self.setNeedsDisplay()
        }
    }
    
    func complete(annotation: Int) {
        // TODO: Index check
        completed[annotation] = true
        self.setNeedsDisplay()
    }
    
    func clearAnnotations() {
        pointArrays = [[]]
        completed = [false]
        self.setNeedsDisplay()
    }
    
    func getPoints() -> [Point] {
        guard let offsetX = offsetX, let offsetY = offsetY else {
            print("There is no views")
            return []
        }
        var points: [Point] = []
        for point in pointArrays[0] {
            points.append(Point(x: point.x - offsetX, y: point.y - offsetY))
        }
        return points
    }
}
