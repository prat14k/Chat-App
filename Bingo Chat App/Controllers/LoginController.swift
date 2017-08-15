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

    @IBOutlet weak var registerNameTF: UITextField!
    @IBOutlet weak var registerEmailTF: UITextField!
    @IBOutlet weak var registerPasswordTF: UITextField!
    
    @IBOutlet weak var loginEmailTF: UITextField!
    @IBOutlet weak var loginPasswordTF: UITextField!
    
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var registerView: UIView!
   
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var buttonYPosContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerView.layer.cornerRadius = 5.0;
        loginView.layer.cornerRadius = 5.0;
        submitBtn.layer.cornerRadius = 5.0;
        submitBtn.tag = 1
        loginView.isHidden = true
        loginView.isUserInteractionEnabled = false
        
    }

    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
    
        let index = sender.selectedSegmentIndex
        
        submitBtn.tag = index
        submitBtn.setTitle(sender.titleForSegment(at: index), for: .normal)
        
        if(index == 1){
            loginView.isHidden = true
            loginView.isUserInteractionEnabled = false
           
            registerView.isHidden = false
            registerView.isUserInteractionEnabled = true
            buttonYPosContraint.priority = 999
            
        }
        else{
            loginView.isHidden = false
            loginView.isUserInteractionEnabled = true
  
            registerView.isHidden = true
            registerView.isUserInteractionEnabled = false
            
            buttonYPosContraint.priority = 997
            
        }
        
    }
    
    
    @IBAction func loginRegisterAction(_ sender: UIButton) {
        let tag = sender.tag
        
        if(tag == 0){
            loginAction()
        }
        else{
            registerAction()
        }
        
    }
    
    func loginAction(){
        let email = loginEmailTF.text
        let password = loginPasswordTF.text
      
        if email == nil || password == nil {
            
            print("Empty Fields")
            return
            
        }
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error != nil {
                print("Error Signin: ",error ?? "")
                return
            }
            
            print("Successful Signin")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func registerAction() {
        
        let email = registerEmailTF.text
        let password = registerPasswordTF.text
        let name = ((registerNameTF.text == nil) ? "" : registerNameTF.text)
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
                
                self.dismiss(animated: true, completion: nil)
            })
            
        }
        
        
    }
    
}
