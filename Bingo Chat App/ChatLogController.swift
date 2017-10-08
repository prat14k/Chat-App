//
//  ChatLogController.swift
//  Bingo Chat App
//
//  Created by Prateek on 02/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UITableViewDelegate,UITableViewDataSource , UITextFieldDelegate {
    
    var messages = [Message]()
    
    @IBOutlet weak var tableView: UITableView!
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = messages[indexPath.row]
        var nxtMsg : Message! = nil

        if((indexPath.row+1) < self.messages.count){
            nxtMsg = messages[indexPath.row+1]
        }
        
        var cellID : String! = ""
        
        if(msg.fromID == Auth.auth().currentUser?.uid){
            cellID = "sentMessageCell"
        }
        else{
            if(nxtMsg != nil){
                if(nxtMsg.toID == Auth.auth().currentUser?.uid){
                    cellID = "recievedMessageCellN"
                }
                else{
                    cellID = "recievedMessageCell"
                }
            }
            else{
                cellID = "recievedMessageCellN"
                if((indexPath.row+1) == self.messages.count){
                    cellID = "recievedMessageCell"
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BubbleCell
        
        cell.msgLabel.text = msg.msg
        
        if(cellID == "recievedMessageCell"){
            
            if let imgUrl = user?.profileImageUrl{
                cell.toIDImage.loadImageUsingURLString(imgUrl)
            }
        }
        
        return cell
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
                            self.tableView.reloadData()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsgAction(sendBtn)
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 750
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
}
