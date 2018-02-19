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

    @IBOutlet weak var collectionView : UICollectionView!
    
    var array = [1,1,1,2,2,2,1,2,2,2,2,2,1,2,2,2,1,1,1,1,1,2,2,2,2,1,2,1,2,2,1,1,2,2,1,2,1,2,1,2,1,2,1,2,2,2,1,1,1,1,1,2,1,2,1]
    
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        loadImageUsingURLString("https://media.creativemornings.com/uploads/user/avatar/19379/small_the_new_avatar_512.png")
        
//        imgView.backgroundColor = UIColor.colorFromHexString("#00f235")
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        collectionView.scrollToItem(at: IndexPath(item: array.count - 1, section: 0), at: .bottom, animated: true)
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
    
    @IBAction func addItem(){
        array[array.count - 1] = (array[array.count - 1] == 1 ? 2 : 1)
        array.append(Int(arc4random_uniform(2).toIntMax()) + 1)
        collectionView.insertItems(at: [IndexPath(item: array.count - 1, section: 0)])
        collectionView.reloadItems(at: [IndexPath(item: array.count - 2, section: 0)])
        collectionView.scrollToItem(at: IndexPath(item: array.count - 1, section: 0), at: .bottom, animated: true)
    }
    
}


extension DummyVC : UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell\(array[indexPath.row])", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
}


