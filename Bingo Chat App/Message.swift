//
//  Message.swift
//  Bingo Chat App
//
//  Created by Prateek on 03/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    var toID : String!
    var fromID : String!
    var msg : String!
    var timestamp : NSNumber!
    
    var msgImgURL : String!
    
    var imgHght : NSNumber!
    var imgWidth : NSNumber!
    
    func chatPartnerID() -> String!{
        
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
        
    }
    
}
