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
                user.setValuesForKeys(dictionary)
                self.usersCollection.append(user)
                
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = usersCollection[indexPath.row].name
        cell.detailTextLabel?.text = usersCollection[indexPath.row].email
        return cell
    }
    
 
}
