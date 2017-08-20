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
    
    func loadImageUsingURLString(_ url : String!){
        
        self.image = nil
        
        if url == nil || url.isEmpty{
            return
        }
        
        if let img = imgCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = img
            print(2)
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
                    
                    return
                }
                
                print(1)
                
                //print(response.result.value)
                
                if let imgData = UIImage(data: response.result.value!) {
                    
                    
                    imgCache.setObject(imgData, forKey: url as AnyObject)
                    
                    self.image = imgData
                }
                
        }
        
    }
    
    
}
