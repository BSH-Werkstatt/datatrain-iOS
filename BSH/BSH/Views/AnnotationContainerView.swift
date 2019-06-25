//
//  AnnotationContainerView.swift
//  BSH
//
//  Created by Baris Sen on 6/26/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import UIKit

class AnnotationContainerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !(subview is AnnotationView) {
                return false
            }
            let subview = subview as! AnnotationView
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.isPointInsideAnnotation(point: point) {
                return true
            }
        }
        return false
    }
}
