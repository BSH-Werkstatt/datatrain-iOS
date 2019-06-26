//
//  AnnotationView.swift
//  BSH
//
//  Created by Baris Sen on 6/20/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import UIKit

class AnnotationView: UIView {
    
    var annotation: Annotation?
    var selected = false
    
    private static var offsetX: CGFloat?
    private static var offsetY: CGFloat?
    private static var imageSizeX: CGFloat?
    private static var imageSizeY: CGFloat?
    private static var imageScale: CGFloat?
    
    private static var fillColor: UIColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(0.5))
    
    private static var strokeColor: UIColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(1.0))
    
    private static var pointColor: UIColor = UIColor(displayP3Red: CGFloat(200.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(1.0))
    
    private static var selectedStrokeColor: UIColor = UIColor(displayP3Red: CGFloat(100.0/255.0), green: CGFloat(200.0/255.0), blue: CGFloat(100.0/255.0), alpha: CGFloat(1.0))
    
    private static var selectedFillColor: UIColor = UIColor(displayP3Red: CGFloat(100.0/255.0), green: CGFloat(200.0/255.0), blue: CGFloat(100.0/255.0), alpha: CGFloat(0.5))

    override func draw(_ rect: CGRect) {
        if let annotation = annotation {
            let path = UIBezierPath()
            path.lineWidth = 3.0
            if annotation.points.count >= 1 && annotation.completed {
                // There is a compeleted path
                path.move(to: annotation.points[0])
                if annotation.points.count > 1 {
                    for i in 1...annotation.points.count - 1 {
                        path.addLine(to: annotation.points[i])
                    }
                }
                path.close()
                if selected {
                    AnnotationView.selectedStrokeColor.setStroke()
                    AnnotationView.selectedFillColor.setFill()

                } else {
                    AnnotationView.strokeColor.setStroke()
                    AnnotationView.fillColor.setFill()
                }
                path.fill()
                path.stroke()
            } else if annotation.points.count >= 1 && !annotation.completed {
                // There is an uncompleted path
                path.move(to: annotation.points[0])
                if annotation.points.count > 1 {
                    for i in 1...annotation.points.count - 1 {
                        path.addLine(to: annotation.points[i])
                    }
                }
                if let temporaryPoint = annotation.temporaryPoint {
                    path.addLine(to: temporaryPoint)
                }
                AnnotationView.strokeColor.setStroke()
                path.stroke()
            }
            if annotation.points.count > 1 {
                annotation.points.forEach({ (x: CGPoint) -> Void in
                    let path = UIBezierPath(ovalIn: CGRect(x: x.x - 2.5, y: x.y - 2.5, width: 5.0, height: 5.0))
                    if selected {
                        AnnotationView.selectedStrokeColor.setFill()
                    } else {
                        AnnotationView.pointColor.setFill()
                    }
                    path.fill()
                })
            }
        }
    }
    
    static func setOffsetVariables(offsetX: CGFloat, offsetY: CGFloat) {
        AnnotationView.offsetX = offsetX
        AnnotationView.offsetY = offsetY
    }
    
    static func setImageSize(imageSizeX: CGFloat, imageSizeY: CGFloat) {
        AnnotationView.imageSizeX = imageSizeX
        AnnotationView.imageSizeY = imageSizeY
    }
    
    static func setImageScale(imageScale: CGFloat) {
        AnnotationView.imageScale = imageScale
    }
    
    func getPoints() -> [Point] {
        guard let offsetX = AnnotationView.offsetX, let offsetY = AnnotationView.offsetY,
            let imageScale = AnnotationView.imageScale, let annotation = annotation else {
            print("There is no views")
            return []
        }

        var points: [Point] = []
        var counter = 0
        for point in annotation.points {
            points.append(Point(x: (point.x - offsetX) / imageScale, y: (point.y - offsetY) / imageScale))
        }
        counter += 1
        return points
    }
    
    func isPointInsideAnnotation(point: CGPoint) -> Bool {
        guard let annotation = annotation, annotation.points.count > 2 else {
            return false
        }
        let path = UIBezierPath()
        path.move(to: annotation.points[0])
        for i in 1...annotation.points.count - 1 {
            path.addLine(to: annotation.points[i])
        }
        path.close()
        return path.contains(point)
    }
}

