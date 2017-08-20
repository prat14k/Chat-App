//
//  AlertAction.swift
//  Bingo Chat App
//
//  Created by Prateek on 20/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit

class AlertMsg: NSObject {

    static func alertAction(_ title:String! ,_ message : String?, _ target:UIViewController!){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (alert) in
            print("Done")
        }
        
        alert.addAction(okayAction)
        
        target.present(alert, animated: true) { 
            
        }
        
    }
    
    
}
