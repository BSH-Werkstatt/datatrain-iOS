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
    var minY: CGFloat?
    var isOverTheFinger: Bool = true
    
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
        touchPoint = pt
        var x = touchPoint.x
        if x + bounds.width / 2 > superview!.bounds.maxX {
            x = superview!.bounds.maxX - (bounds.width / 2)
        }
        if x - (bounds.width / 2) < superview!.bounds.minX {
            x = superview!.bounds.minX + (bounds.width / 2)
        }
        var y = touchPoint.y + (isOverTheFinger ?  -150 : 150)
        if isOverTheFinger {
            if let minY = minY, y - bounds.height < minY {
                y = touchPoint.y + 150
                isOverTheFinger = false
            }
        } else {
            if y + (bounds.height / 2) > superview!.bounds.maxY {
                y = touchPoint.y - 150
                isOverTheFinger = true
            }
        }
        self.center = CGPoint(x: x, y: y)
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
