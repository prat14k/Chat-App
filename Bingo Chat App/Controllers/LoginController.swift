//
//  LoginController.swift
//  Bingo Chat App
//
//  Created by Prateek on 15/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var detailsViewOutlet: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsViewOutlet.layer.cornerRadius = 5.0;
        submitBtn.layer.cornerRadius = 5.0;
        
    }

    @IBAction func registerAction(_ sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let name = ((nameTextField.text == nil) ? "" : nameTextField.text)
        if email == nil || password == nil {
            
            print("Empty Fields")
            return
        
        }
        
        Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
            if error != nil {
                print("User Create Error: ", error ?? "")
                return
            }
            
            let uid = user?.uid
            if uid == nil {
                return
            }
            
            let dbLink = Database.database().reference(fromURL: "https://bingo-chatbase.firebaseio.com/")
            
            let user = dbLink.child("users").child(uid!)
            
            let userData = ["name" : name, "email" : email]
            
            user.updateChildValues(userData, withCompletionBlock: { (error, dbRef) in
                if error != nil {
                    print("Data Adding Error: ", error ?? "")
                    return
                }
                
                print("Successful Addition User Info")
            })
            
        }
        
        
    }
    
}
