//
//  ImageCache.swift
//  Bingo Chat App
//
//  Created by Prateek on 20/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Alamofire

let imgCache = NSCache<AnyObject, AnyObject>()


extension UIImageView {
    
    func loadImageUsingURLString(_ url : String!, isToBeCircled shouldBeCircled : Bool = true){
        
        self.image = nil
        let tag = self.tag
        
        if url == nil || url.isEmpty || url == ""{
            self.image = UIImage(named: "placeholderPic")
            return
        }
        
        if let img = imgCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = img
            
            if shouldBeCircled  {
                self.layer.cornerRadius = self.frame.size.height/2.0
            }
            self.backgroundColor = UIColor.clear
            self.layer.masksToBounds = true
            self.clipsToBounds = true
            
            return
        }
        
        Alamofire.request(
            URL(string: url)!,
            method: .get,
            parameters: nil)
            .validate()
            .responseData { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                    self.image = UIImage(named: "placeholderPic")
                    return
                }
                
                //print(response.result.value)
                
                if let responseValue = response.result.value {
                    if let imgData = UIImage(data: responseValue) {
                        if tag == self.tag {
                            imgCache.setObject(imgData, forKey: url as AnyObject)
                            
                            self.image = imgData
                            
                            if shouldBeCircled  {
                                self.layer.cornerRadius = self.frame.size.height/2.0
                            }
                            self.backgroundColor = UIColor.clear
                            self.layer.masksToBounds = true
                            self.clipsToBounds = true
                        }
                    }
                }
        }
        
    }
    
    
}
