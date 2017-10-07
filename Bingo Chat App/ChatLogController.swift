//
//  ChatLogController.swift
//  Bingo Chat App
//
//  Created by Prateek on 02/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource , UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var messages = [Message]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var user : Users?{
        
        didSet{
            
            if(user?.name == ""){
                navigationItem.title = "Chat"
            }
            else{
                navigationItem.title = user?.name
            }
            
            observeMessages()
        }
        
    }
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgTF: UITextField!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as? BubbleCell
        
        let msg = messages[indexPath.row]
        
        cell?.msgTextView.text = msg.msg
        
        return cell!
    }
    
    func observeMessages(){
        
        let ref = Database.database().reference().child("messages")
        let uid = Auth.auth().currentUser?.uid
        let msgsDBRef = ref.child("userMsgDB").child(uid!)
        msgsDBRef.observe(.childAdded, with: { (snapShot) in
            
            if (snapShot.key != "" ){
                
                ref.child(snapShot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let msgDict = snapshot.value as? [String:Any]{
                        
                        let message = Message()
                        message.setValuesForKeys(msgDict)
                        
                        self.messages.append(message)
                        self.messages.sort(by: { (msg1, msg2) -> Bool in
                            return (msg1.timestamp?.doubleValue)! < (msg2.timestamp?.doubleValue)!
                        })
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                    }
                    
                }, withCancel: nil)
                
            }
            
        }, withCancel: nil)
        
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
                    let vals = [entryChild.key : 1]
                    
                    let userRef = msgDB.child(fromID!)
                    userRef.updateChildValues(vals)
                    
                    msgDB.child(toID!).updateChildValues(vals)
                })
                
                
                msgTF.text = ""
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 80)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsgAction(sendBtn)
        return true
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
}
