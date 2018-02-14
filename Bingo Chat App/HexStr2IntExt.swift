//
//  Hex2Decimal.swift
//  Bingo Chat App
//
//  Created by Prateek Sharma on 13/02/18.
//  Copyright © 2018 14K. All rights reserved.
//

import Foundation


extension String {
    
    func reverseStr() -> String {
        var reverseStr = ""
        for character in self {
            reverseStr = String(character) + reverseStr
        }
        return reverseStr
    }
    
    func convertToInt() -> Int {
        
        if self.count < 1 {
            return 0
        }
        
        var string = self.lowercased().reverseStr()
        string = string.replacingOccurrences(of: "#", with: "")
        
        let num0_code = ("0" as NSString).character(at: 0)
        let a_code = ("a" as NSString).character(at: 0)
        
        var multiplier = 1
        var ans = 0
        
        for ch in string {
            
            let charCode = (String(ch) as NSString).character(at: 0)
            
            var val = 0
            
            if isCharacterNumeric(charCode: charCode) {
                val = NSNumber(value: charCode).intValue - NSNumber(value: num0_code).intValue
            }
            else if isCharacterLowerCasedHexAlpha(charCode: charCode) {
                val = NSNumber(value: charCode).intValue - NSNumber(value: a_code).intValue + 10
            }
            else {
                return -1
            }
            
            ans = ans + (val * multiplier)
            multiplier = multiplier * 16
            
        }
        
        
        return ans
        
    }
    
    func isCharacterNumeric(charCode : unichar) -> Bool {
        
        let num0_code = ("0" as NSString).character(at: 0)
        let num9_code = ("9" as NSString).character(at: 0)
        
        if (num0_code ... num9_code).contains(charCode) {
            return true
        }
        
        return false
    }

    private func isCharacterUpperCasedHexAlpha(charCode : unichar) -> Bool {
        
        let A_code = ("A" as NSString).character(at: 0)
        let F_code = ("F" as NSString).character(at: 0)
        
        if (A_code ... F_code).contains(charCode) {
            return true
        }
        
        return false
    }

    private func isCharacterLowerCasedHexAlpha(charCode : unichar) -> Bool {
        
        let a_code = ("a" as NSString).character(at: 0)
        let f_code = ("f" as NSString).character(at: 0)
        
        if (a_code ... f_code).contains(charCode) {
            return true
        }
        
        return false
    }

    func isaHexLetter(_ charCode : unichar) -> Bool {
        
        if isCharacterNumeric(charCode: charCode) {
            return true
        }
        
        if isCharacterLowerCasedHexAlpha(charCode: charCode) {
            return true
        }
        
        if isCharacterUpperCasedHexAlpha(charCode: charCode) {
            return true
        }
        
        return false
    }

}
