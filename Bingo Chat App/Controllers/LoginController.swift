//
//  LoginController.swift
//  Bingo Chat App
//
//  Created by Prateek on 15/08/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicUpdateLabel: UILabel!
    
    let imagePickerController : UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        return imagePickerController
    }()
    
    let gradientLayer : CAGradientLayer = {
       
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ UIColor(red: 89.0/255.0, green: 23.0/255.0, blue: 11.0/255.0, alpha: 1.0).cgColor , UIColor(red: 142.0/255.0, green: 14.0/255.0, blue: 0, alpha: 1.0).cgColor , UIColor(red: 89.0/255.0, green: 23.0/255.0, blue: 11.0/255.0, alpha: 1.0).cgColor ]
        return gradientLayer
    }()
    
    @IBOutlet weak var nameTFContainer: UIView!
    @IBOutlet weak var emailTFContainer: UIView!
    @IBOutlet weak var passwordTFContainer: UIView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var scrollViewBottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        imagePickerController.delegate = self
    }

    @IBAction func imagePickAction(_ sender: UITapGestureRecognizer) {
        
        if(segmentOutlet.selectedSegmentIndex == 0)
        {
            return;
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillAppear(_ notification : Notification) {
        scrollViewBottomContraint.constant = 300
        self.scrollView.layoutIfNeeded()
    }
    
    @objc func keyboardWillDisappear(_ notification : Notification) {
        scrollViewBottomContraint.constant = 60
        self.scrollView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImg = info["UIImagePickerControllerEditedImage"]  as? UIImage{
            profileImage.image = editedImg
        }
        else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImage.image = originalImg
        }
        
        dismiss(animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image Pick Cancelled")
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
    
        let index = sender.selectedSegmentIndex
        
        submitBtn.tag = index
        submitBtn.setTitle(sender.titleForSegment(at: index), for: .normal)
        
        if(index == 1){
//            profileImage.isHidden = false
            nameTFContainer.isHidden = false
            profilePicUpdateLabel.isHidden = false
            profileImage.image = UIImage(named: Constants.uploadImagePlaceholder)

            emailTF.text = ""
            passwordTF.text = ""
            
            submitBtn.setTitle("SIGNUP", for: .normal)
        }
        else{
//            profileImage.isHidden = true
            profileImage.image = UIImage(named: Constants.appLogo)
            nameTFContainer.isHidden = true
            profilePicUpdateLabel.isHidden = true
            
            nameTF.text = ""
            emailTF.text = ""
            passwordTF.text = ""
            submitBtn.setTitle("LOGIN", for: .normal)
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
        
        if !checkCredentialsLiability() {
            return
        }
        
        let email = emailTF.text
        let password = passwordTF.text
      
        SVProgressHUD.show(withStatus: "Logging in")
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            SVProgressHUD.dismiss()
            if error != nil {
                print("Error Signin: ",error ?? "")
                
                AlertMsg.alertAction("Signin Error", error!.localizedDescription, self)
                return
            }
            print("Successful Signin")
            self.passwordTF.text = ""
            self.emailTF.text = ""
//            self.dismiss(animated: true, completion: nil)
            
            UserDefaults.standard.set(user?.uid, forKey: Constants.cookieKeyName)
            
            self.performSegue(withIdentifier: "chatScreenSegue", sender: nil)
        }
        
    }
    
    
    func addUserFirebase(_ userData:[String:Any], uid: String){
        let dbLink = Database.database().reference()
        
        let user = dbLink.child("users").child(uid)
        
        
        user.updateChildValues(userData, withCompletionBlock: { (error, dbRef) in
            SVProgressHUD.dismiss()
            if error != nil {
                print("Data Adding Error: ", error ?? "")
                
                AlertMsg.alertAction("Unable to Add User", error!.localizedDescription, self)
                
                return
            }
            
            print("Successful Addition User Info")
            
            self.passwordTF.text = ""
            self.emailTF.text = ""
            //            self.dismiss(animated: true, completion: nil)
            
            UserDefaults.standard.set(uid, forKey: Constants.cookieKeyName)
            
            self.performSegue(withIdentifier: "chatScreenSegue", sender: nil)
        })
    }
    
    func checkCredentialsLiability() -> Bool{
        self.view.endEditing(true)
        
        if let email = emailTF.text {
            if !isEmailValid(email: email) {
                AlertMsg.alertAction("The entered email is not valid", "The entered email doesn't follow the email id character rules", self)
                return false
            }
        }
        else{
            return false
        }
        
        if let password = passwordTF.text {
            if password.count < 6 {
                AlertMsg.alertAction("The entered password is too small", "The minimum length for the password is 6 letters", self)
                return false
            }
        }
        else{
            return false
        }
        
        return true
    }
    
    func isEmailValid(email : String) -> Bool {
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return false
        }
        
        //        let stricterFilter = true
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        //        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        //        let emailRegex = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        
        return emailTest.evaluate(with:email)
    }
    
    func registerAction() {
        
        if !checkCredentialsLiability() {
            return
        }
        
        let email = emailTF.text
        let password = passwordTF.text
        let name = ((nameTF.text == nil) ? "" : nameTF.text)
        
        SVProgressHUD.show(withStatus: "Registering a new user")
        Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
            if error != nil {
                print("User Create Error: ", error ?? "")
                
                AlertMsg.alertAction("Unable To Create User", error!.localizedDescription, self)
                SVProgressHUD.dismiss()
                return
            }
            
            let uid = user?.uid
            if uid == nil {
                return
            }
            
            let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.4)! as NSData
            let defaultImg = UIImageJPEGRepresentation(UIImage(named: Constants.uploadImagePlaceholder)!,0.4)! as NSData
            
            if uploadData.isEqual(defaultImg) {
                
                let userData = ["name" : name, "email" : email , "profileImageUrl" : ""]
                
                self.addUserFirebase(userData, uid: uid!)
                return

            }
            
            let customUuid = NSUUID().uuidString
            
            let storage = Storage.storage().reference().child("profile_images").child("\(customUuid).png")
            
            
                storage.putData(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("error: ",error ?? "")
                        
                        AlertMsg.alertAction("Unable to upload image", error!.localizedDescription, self)
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    if let profileImgURL = metadata?.downloadURL()?.absoluteString {
                      
                        
                        let userData = ["name" : name, "email" : email , "profileImageUrl" : profileImgURL]
                        
                        self.addUserFirebase(userData, uid: uid!)
                    }
                })
            
            
            
            
        }
        
        
    }
    
}


extension LoginController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let originPt = view.convert(textField.frame.origin, from: textField.superview)
        let lastPoint = textField.frame.size.height + originPt.y
        
        if lastPoint > (view.frame.size.height - 250) {
            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: lastPoint - (self.view.frame.size.height - 250) + 30)
            })
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == nameTF {
            emailTF.becomeFirstResponder()
        }
        else if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            if submitBtn.tag == 0 {
                loginAction()
            }
            else{
                registerAction()
            }
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
}

