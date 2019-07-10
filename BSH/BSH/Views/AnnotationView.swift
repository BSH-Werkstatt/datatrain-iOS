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
    var delegate: AnnotateImageViewController?
    var labelView: UILabel?
    
    var surroundingRect: UIBezierPath {
        let path = UIBezierPath()
        if let annotation = annotation {
            path.move(to: annotation.points[0])
            if annotation.points.count > 1 {
                for i in 1...annotation.points.count - 1 {
                    path.addLine(to: annotation.points[i])
                }
            }
        }
        return UIBezierPath(rect: path.bounds)
    }
    
    private static var offsetX: CGFloat?
    private static var offsetY: CGFloat?
    private static var imageSizeX: CGFloat?
    private static var imageSizeY: CGFloat?
    private static var imageScale: CGFloat?
    
    static var fillColor = #colorLiteral(red: 0.5, green: 0.4328446062, blue: 0.6674604024, alpha: 0.6042166096)
    static var strokeColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    static var selectedStrokeColor = #colorLiteral(red: 1, green: 0, blue: 0.6634275317, alpha: 1)
    static var selectedFillColor = #colorLiteral(red: 1, green: 0, blue: 0.6600222588, alpha: 0.5981271404)
    static var firstPointColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
    static var lastPointColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    
    static var viewScale: CGFloat = 1.0
    
    func scale(_ value: CGFloat) -> CGFloat {
        return value * AnnotationView.viewScale
    }

    override func draw(_ rect: CGRect) {
        if let annotation = annotation {
            let path = UIBezierPath()
            path.lineWidth = scale(3.0)
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
                AnnotationView.selectedStrokeColor.setStroke()
                path.stroke()
            }
            if annotation.points.count > 1 {
                annotation.points.forEach({ (x: CGPoint) -> Void in
                    var path: UIBezierPath
                    if !annotation.completed, annotation.startPoint == x {
                        path = UIBezierPath(ovalIn: CGRect(x: x.x - scale(10), y: x.y - scale(10), width: scale(20.0), height: scale(20.0)))
                        AnnotationView.firstPointColor.setFill()
                    } else {
                        path = UIBezierPath(ovalIn: CGRect(x: x.x - scale(2.5), y: x.y - scale(2.5), width: scale(5.0), height: scale(5.0)))
                        if selected || !annotation.completed {
                            AnnotationView.selectedStrokeColor.setFill()
                        } else {
                            AnnotationView.strokeColor.setFill()
                        }
                    }
                    path.fill()
                })
                if !annotation.completed {
                    let temporaryPointPath = UIBezierPath(ovalIn: CGRect(x: annotation.endPoint!.x - scale(10), y: annotation.endPoint!.y - scale(10), width: scale(20.0), height: scale(20.0)))
                    if let drawingEnabled = delegate?.drawingEnabled, !drawingEnabled {
                        temporaryPointPath.lineWidth = scale(8)
                        AnnotationView.selectedStrokeColor.setStroke()
                        temporaryPointPath.stroke()
                    }
                    AnnotationView.lastPointColor.setFill()
                    temporaryPointPath.fill()
                }
            }
            if annotation.completed {
                let surroundingRect = UIBezierPath(rect: path.bounds)
                surroundingRect.setLineDash([32.0, 16.0], count: 2, phase: 0.0)
                surroundingRect.lineWidth = scale(2)
                if selected {
                    AnnotationView.selectedStrokeColor.setStroke()
                } else {
                    AnnotationView.strokeColor.setStroke()
                }
                surroundingRect.stroke()
            }
            if let labelView = labelView {
                labelView.backgroundColor = selected || !annotation.completed ? AnnotationView.selectedFillColor : AnnotationView.fillColor
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

