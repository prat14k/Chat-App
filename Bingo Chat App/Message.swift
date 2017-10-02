//
//  Message.swift
//  Bingo Chat App
//
//  Created by Prateek on 03/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import Foundation


class Message: NSObject {
    var toID : String!
    var fromID : String!
    var msg : String!
    var timestamp : NSNumber?
}
