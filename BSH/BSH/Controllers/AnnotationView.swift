//
//  AnnotationView.swift
//  BSH
//
//  Created by Baris Sen on 6/20/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import UIKit

class AnnotationView: UIView {
    
    private var pointArrays: [[CGPoint]] = []
    private var completed: [Bool] = []

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = 3.0
        for index in 0...pointArrays.count - 1 {
            if pointArrays[index].count == 1 {
                // There is only one point to draw
                path.move(to: pointArrays[index][0])
                UIColor.darkGray.setStroke()
                path.stroke()
            } else if pointArrays[index].count >= 1 && completed[index] {
                // There is a compeleted path
                path.move(to: pointArrays[index][0])
                for i in 1...pointArrays[index].count - 1 {
                    path.addLine(to: pointArrays[index][i])
                }
                path.close()
                UIColor.darkGray.setStroke()
                UIColor.gray.setFill()
                path.fill()
                path.stroke()
            } else if pointArrays[index].count >= 1 && !completed[index] {
                // There is an uncompleted path
                path.move(to: pointArrays[index][0])
                for i in 1...pointArrays[index].count - 1 {
                    path.addLine(to: pointArrays[index][i])
                }
                UIColor.darkGray.setStroke()
                path.stroke()
            }
        }
    }
    
}
