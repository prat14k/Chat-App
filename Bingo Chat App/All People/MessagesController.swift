//
//  AllPeopleTableController.swift
//  Bingo Chat App
//
//  Created by Prateek on 15/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    
    var messages = [Message]()
    var messagesDict = [String : Message]()
    var usersInfo = [String : Users]()
    
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn(){
        
        if Auth.auth().currentUser?.uid == nil {
            
            self.perform(#selector(presentLoginScreen), with: nil, afterDelay: 0)
        }
        else{
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:Any] {
                    self.setupNavBar(dictionary)
                    
                    self.observeMessages()
                }
                
            })
        }
        
        
    }
    
    
    func observeMessages(){
        
        messages.removeAll()
        messagesDict.removeAll()
        usersInfo.removeAll()
        
        let ref = Database.database().reference().child("messages")
        let uid = Auth.auth().currentUser?.uid
        let msgsDBRef = ref.child("userMsgDB").child(uid!)
        msgsDBRef.observe(.childAdded, with: { (snapShot) in
            
            if (snapShot.key != "" ){
                
                ref.child(snapShot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let msgDict = snapshot.value as? [String:Any]{

                        let message = Message()
                        message.setValuesForKeys(msgDict)
                        
                        if let chatPartnerUID = message.chatPartnerID(){
                            
                            if let tempMSG = self.messagesDict[chatPartnerUID] {
                                if((tempMSG.timestamp?.doubleValue)! < (message.timestamp?.doubleValue)!){
                                    self.messagesDict[chatPartnerUID] = message
                                    self.messages = Array(self.messagesDict.values)
                                    
                                    self.messages.sort(by: { (msg1, msg2) -> Bool in
                                        return (msg1.timestamp?.doubleValue)! > (msg2.timestamp?.doubleValue)!
                                    })
                                    
                                }
                            }
                            else{
                                self.messagesDict[chatPartnerUID] = message
                                self.messages = Array(self.messagesDict.values)
                                
                                self.messages.sort(by: { (msg1, msg2) -> Bool in
                                    return (msg1.timestamp?.doubleValue)! > (msg2.timestamp?.doubleValue)!
                                })
                                
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                    
                }, withCancel: nil)
                
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBar(_ dictionary : [String : Any]){
        
        let titleView = UIView()
        
        let imgV = UIImageView()
        
        if let imgUrl = dictionary["profileImageUrl"] as? String{
            
            imgV.loadImageUsingURLString(imgUrl)
            imgV.layer.cornerRadius = 20
            imgV.layer.masksToBounds = true
        }
        
        let titleL = UILabel()
        
        titleL.text = dictionary["name"] as? String
        
        titleView.addSubview(imgV)
        titleView.addSubview(titleL)
        
        
        let navTitleView = UIView()
        
        navTitleView.addSubview(titleView)
        
        
        
        imgV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addConstraint(NSLayoutConstraint(item: imgV, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        titleView.addConstraint(NSLayoutConstraint(item: imgV, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        imgV.addConstraint(NSLayoutConstraint(item: imgV, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 35.0))
        imgV.addConstraint(NSLayoutConstraint(item: imgV, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 35.0))
        
        titleView.addConstraint(NSLayoutConstraint(item: titleL, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: imgV, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 5.0))
        titleView.addConstraint(NSLayoutConstraint(item: titleL, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        titleView.addConstraint(NSLayoutConstraint(item: titleL, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
        
        navTitleView.addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: navTitleView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        navTitleView.addConstraint(NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: navTitleView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        
        self.navigationItem.titleView = navTitleView
        //self.navigationItem.title = dictionary["name"] as? String
        
    }
    
    
    func presentLoginScreen(_ obj : Any?){
        self.performSegue(withIdentifier: "loginScreenSegue", sender: self)
    }
    
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        
        do{
            try Auth.auth().signOut()
        }
        catch let logoutErr {
            print("Logout Error: ", logoutErr)
            
            AlertMsg.alertAction("Logout Error", logoutErr.localizedDescription, self)
        }
        
        
        messages.removeAll()
        messagesDict.removeAll()
        usersInfo.removeAll()
        self.tableView.reloadData()
        self.perform(#selector(presentLoginScreen), with: nil, afterDelay: 0.1)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewMessageCell
        let msg = self.messages[indexPath.row]
        
        if let chatPartnerID = msg.chatPartnerID() {
            
            let ref = Database.database().reference().child("users").child(chatPartnerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapShot) in
                
                if let dictionary = snapShot.value as? [String : Any] {
                    
                    let user = Users()
                    user.UID = snapShot.key
                    user.setValuesForKeys(dictionary)
                    
                    self.usersInfo[chatPartnerID] = user
                    
                    cell?.userName?.text = user.name
                    
                    if let imgURL = dictionary["profileImageUrl"] as? String{
                        
                        cell?.profileImage.image = UIImage(named: "")
                        cell?.profileImage.loadImageUsingURLString(imgURL)
                        
                    }
                    
                    
                }
                
            }, withCancel: nil)
        }
    
        
        if let seconds = msg.timestamp as? Double{
            
            let dateSecs = Date(timeIntervalSince1970: seconds)
            
            let format = DateFormatter()
            format.dateFormat = "hh:mm:ss a"
            cell?.dateTimestamp.text = format.string(from: dateSecs)
            
        }
        
        cell?.userEmail?.text = msg.msg
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "chatLogSegue", sender: messages[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "chatLogSegue"){
            
            let message = sender as! Message
            
            let vc = segue.destination as? ChatLogController
            
            if let chatPartnerUID = message.chatPartnerID(){
                
                vc?.user = usersInfo[chatPartnerUID]
            }
            
        }
        
    }
    
}
