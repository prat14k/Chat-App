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
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            })
        }
        
        
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
        presentLoginScreen(nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    

}
