//
//  MagnifyView.swift
//  BSH
//
//  Created by Baris Sen on 6/27/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import UIKit

class MagnifyView: UIView {

    var viewToMagnify: UIView!
    var touchPoint: CGPoint!
    var maxY: CGFloat?
    var isOnTheRight: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        // Set border color, border width and corner radius of the magnify view
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 50
        self.layer.masksToBounds = true
    }
    
    func setTouchPoint(pt: CGPoint) {
        let left = CGPoint(x: 85, y: (maxY ?? viewToMagnify.bounds.maxY) - 75)
        let right = CGPoint(x: viewToMagnify.bounds.maxX - 85, y: (maxY ?? viewToMagnify.bounds.maxY) - 75)
        center = isOnTheRight ? right : left
        touchPoint = pt
        if frame.contains(touchPoint) {
            if isOnTheRight {
                isOnTheRight = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.center = left
                }, completion: nil)
            } else {
                isOnTheRight = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.center = right
                }, completion: nil)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 1 * (self.frame.size.width * 0.5), y: 1 * (self.frame.size.height * 0.5))
        context!.scaleBy(x: 2, y: 2) // 1.5 is the zoom scale
        context!.translateBy(x: -1 * (touchPoint.x), y: -1 * (touchPoint.y))
        self.viewToMagnify.layer.render(in: context!)
        
        let path = UIBezierPath(ovalIn: CGRect(x: touchPoint.x - 5, y: touchPoint.y - 5, width: 10, height: 10))
        #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).setFill()
        path.fill()
    }

}
