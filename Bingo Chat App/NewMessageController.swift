//
//  NewMessageController.swift
//  Bingo Chat App
//
//  Created by Prateek on 19/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var usersCollection = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    func fetchUsers(){
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            
            if let dictionary = snapshot.value as? [String:Any]{
                
                let user = Users()
                user.UID = snapshot.key
                
                user.setValuesForKeys(dictionary)
                
                self.usersCollection.append(user)
                
                if let uid = Auth.auth().currentUser?.uid {
                    
                    if uid == user.UID {
                        
                        self.usersCollection.removeLast()
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    print("reload")
                }
                
            }
            
        }, withCancel: nil)
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        return usersCollection.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewMessageCell
        
        cell.userName.text = usersCollection[indexPath.row].name
        cell.userEmail.text = usersCollection[indexPath.row].email
        
        cell.profileImage.loadImageUsingURLString(usersCollection[indexPath.row].profileImageUrl)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "chatLogSegue", sender: usersCollection[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "chatLogSegue"){
            
            let vc = segue.destination as! ChatLogController
            
            vc.user = sender as? Users
            
        }
        
    }
    
}
