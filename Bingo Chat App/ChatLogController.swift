//
//  ChatLogController.swift
//  Bingo Chat App
//
//  Created by Prateek on 02/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource , UITextFieldDelegate {
    
    var user : Users?{
        
        didSet{
            
            if(user?.name == ""){
                navigationItem.title = "Chat"
            }
            else{
                navigationItem.title = user?.name
            }
        }
        
    }
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTF: UITextField!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    @IBAction func sendMsgAction(_ sender: UIButton) {
        
        if let msg = msgTF.text{
            
            if msg != "" {
                
                let messages = Database.database().reference().child("messages")
                
                let entryChild = messages.childByAutoId()
                
                
                let toID = user?.UID
                let fromID = Auth.auth().currentUser?.uid
                let timestamp = NSDate().timeIntervalSince1970
                
                let values = ["msg" : msg , "timestamp" : timestamp , "toID" : toID ?? "" , "fromID" : fromID ?? ""] as [String : Any]
                
                entryChild.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    let msgDB = messages.child("userMsgDB")
                    
                    let userRef = msgDB.child(fromID!)
                    
                    let vals = [entryChild.key : 1]
                    userRef.updateChildValues(vals)
                })
                
                
                msgTF.text = ""
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsgAction(sendBtn)
        return true
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
}
