//
//  UIButtonExtension.swift
//  BSH
//
//  Created by Baris Sen on 7/10/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    /*
     Add right arrow disclosure indicator to the button with normal and
     highlighted colors for the title text and the image
     */
    func disclosureButton(baseColor: UIColor) {
        self.setTitleColor(baseColor, for: .normal)
        self.setTitleColor(baseColor.withAlphaComponent(0.3), for: .highlighted)
        
        guard let image = UIImage(named: "upArrow")?.withRenderingMode(.alwaysTemplate) else {
            return
        }
        guard let imageHighlight = UIImage(named: "upArrow")?.alpha(0.3)?.withRenderingMode(.alwaysTemplate) else {
            return
        }
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(image, for: .normal)
        self.setImage(imageHighlight, for: .highlighted)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.bounds.size.width - 40, bottom: 0, right: 20);
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 60);
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
}

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
