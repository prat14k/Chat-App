//
//  UIColorHexExt.swift
//  Bingo Chat App
//
//  Created by Prateek Sharma on 13/02/18.
//  Copyright © 2018 14K. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func colorFromHexString(_ string : String) -> UIColor? {
        let string = string.replacingOccurrences(of: "#", with: "")
        
        if string.count != 6 {
            return nil
        }
        
        var i = 0
        
        var rgbArr = [Int]()
        
        while i < 6 {
            
            let startIndex = string.index(string.startIndex, offsetBy: i)
            let endIndex = string.index(string.startIndex, offsetBy: i + 2)
            let subString = string.substring(with: startIndex..<endIndex)
            
            let colorInt = subString.convertToInt()
            
            if colorInt < 0 {
                return nil
            }
            
            rgbArr.append(colorInt)
            
            i = i + 2
        }
        
        if rgbArr.count < 3 {
            return nil
        }
        
        return UIColor.rgbColor(red: rgbArr[0], green: rgbArr[1], blue: rgbArr[2])
    }
    
    static func rgbColor(red : Int , green : Int , blue : Int) -> UIColor? {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
}
