//
//  RoundCorneredView.swift
//  Bingo Chat App
//
//  Created by Prateek Sharma on 16/02/18.
//  Copyright © 2018 14K. All rights reserved.
//

import UIKit

@IBDesignable
class RoundCorneredView: UIView {

    @IBInspectable var maxRadius : CGFloat = 15 {
        didSet {
            setup()
        }
    }
    @IBInspectable var minRadius : CGFloat = 4 {
        didSet {
            layer.cornerRadius = minRadius
        }
    }
    
    @IBInspectable var bottomRightCorner : Bool = false {
        didSet {
            setup()
        }
    }
    @IBInspectable var bottomLeftCorner : Bool = false {
        didSet {
            setup()
        }
    }
    @IBInspectable var topRightCorner : Bool = false {
        didSet {
            setup()
        }
    }
    @IBInspectable var topLeftCorner : Bool = false {
        didSet {
            setup()
        }
    }
    
    
    override func layoutSubviews() {
        setup()
        super.layoutSubviews()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
    
    func setup() {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
        var corners : UIRectCorner = []
        if topLeftCorner {
            corners.insert(.topLeft)
        }
        if topRightCorner {
            corners.insert(.topRight)
        }
        if bottomLeftCorner {
            corners.insert(.bottomLeft)
        }
        if bottomRightCorner {
            corners.insert(.bottomRight)
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: maxRadius, height: maxRadius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

