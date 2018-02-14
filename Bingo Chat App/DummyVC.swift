//
//  DummyVC.swift
//  Bingo Chat App
//
//  Created by Prateek on 20/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Alamofire

class DummyVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        loadImageUsingURLString("https://media.creativemornings.com/uploads/user/avatar/19379/small_the_new_avatar_512.png")
        
        imgView.backgroundColor = UIColor.colorFromHexString("#00f235")
        
    }
    
    
    func loadImageUsingURLString(_ url : String!){
        
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
                
                if let imgData = response.result.value {
                    self.imgView.image = UIImage(data: imgData)
                }
                
        }
        print(11)
        
    }
    
    
}
