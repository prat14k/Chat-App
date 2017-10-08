//
//  PaddedLabel.swift
//  Bingo Chat App
//
//  Created by Prateek on 08/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {

    
    @IBInspectable var topInsets : CGFloat = 0.0
    @IBInspectable var leftInsets : CGFloat = 0.0
    @IBInspectable var bottomInsets : CGFloat = 0.0
    @IBInspectable var rightInsets : CGFloat = 0.0
    
    override func drawText(in rect: CGRect) {

        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(topInsets, leftInsets, bottomInsets, rightInsets)))
        
    }
    
    override var intrinsicContentSize: CGSize{
        
        get{
            var size = super.intrinsicContentSize
            size.height += topInsets + bottomInsets
            size.width += rightInsets + leftInsets
            return size
        }
        
    }
    
}
