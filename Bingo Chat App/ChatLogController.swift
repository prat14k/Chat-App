//
//  ChatLogController.swift
//  Bingo Chat App
//
//  Created by Prateek on 02/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UIViewController, UITableViewDelegate,UITableViewDataSource , UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var messages = [Message]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableViewBottomContraint: NSLayoutConstraint!
    
    var user : Users?{
        
        didSet{
            
            if(user?.name == ""){
                navigationItem.title = "Chat"
            }
            else{
                if(user?.profileImageUrl == ""){
                    navigationItem.title = user?.name
                }
                else{
                    self.setupNavBar(user)
                }
            }
            
            observeMessages()
        }
        
    }

    func setupNavBar(_ userDict : Users!){
        
        let titleView = UIView()
        
        let imgV = UIImageView()
        
        if let imgUrl = userDict.profileImageUrl {
            
            imgV.loadImageUsingURLString(imgUrl)
            imgV.layer.cornerRadius = 20
            imgV.layer.masksToBounds = true
        }
        
        let titleL = UILabel()
        
        titleL.text = userDict.name
        
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
        
    }
    
    var sendBtn: UIButton!
    var imageSendBtn: UIButton!
    var msgTF: UITextField!

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = messages[indexPath.row]
        var cellID : String! = "MessageCell"
//        var nxtMsg : Message! = nil
//
//        if((indexPath.row+1) < self.messages.count){
//            nxtMsg = messages[indexPath.row+1]
//        }
//
//
//
//        if(msg.fromID == Auth.auth().currentUser?.uid){
//            cellID = "sentMessageCell"
//        }
//        else{
//            if(nxtMsg != nil){
//                if(nxtMsg.toID == Auth.auth().currentUser?.uid){
//                    cellID = "recievedMessageCellN"
//                }
//                else{
//                    cellID = "recievedMessageCell"
//                }
//            }
//            else{
//                cellID = "recievedMessageCellN"
//                if((indexPath.row+1) == self.messages.count){
//                    cellID = "recievedMessageCell"
//                }
//            }
//        }
        
        
        var pref : String!
        if(msg.fromID == Auth.auth().currentUser?.uid){
            pref = "sent"
        }
        else{
            pref = "recieved"
        }
        
        if msg.msg != nil {
            cellID = pref + cellID
        }
        else if msg.msgVideoURL != nil {
            cellID = pref + "Video" + cellID
        }
        else if msg.msgImgURL != nil {
            cellID = pref + "Image" + cellID
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BubbleCell
        
        cell.setupCell(msg)
        
        if msg.msgVideoURL == nil ,(msg.msgImgURL) != nil{
        
            let gesture = UITapGestureRecognizer(target: self, action: #selector(zoomAction))
            gesture.numberOfTapsRequired = 1
            cell.msgImageView.addGestureRecognizer(gesture)
            
        }
        
        
        
        
        
//        if(cellID == "recievedMessageCell"){
//
//            if let imgUrl = user?.profileImageUrl{
//                cell.toIDImage.loadImageUsingURLString(imgUrl)
//            }
//        }
//
        
        return cell
    }
    
    func observeMessages(){
        
        let ref = Database.database().reference().child("messages")
        let uid = Auth.auth().currentUser?.uid
        let msgsDBRef = Database.database().reference().child("userMsgDB").child(uid!).child((user?.UID!)!)
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
                            self.tableView.layoutIfNeeded()
                            if self.messages.count > 0 {
                                self.tableView.scrollToRow(at: IndexPath(row: (self.messages.count - 1), section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                            }
                        }
                    }
                    
                }, withCancel: nil)
                
            }
            
        }, withCancel: nil)
        
    }
    
    @IBAction func sendMsgAction(_ sender: UIButton) {
        
        if let msg = msgTF.text{
            
            if msg != "" {
                let dict : [String:Any] = ["msg" : msg]
                self.sendMsg2Firebase(dict)
                
                msgTF.text = ""
                
            }
            
        }
        
    }

    @IBAction func sendImageAction(_ sender: UIButton) {
        
        let imagePickerContr = UIImagePickerController()
        
        imagePickerContr.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerContr.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imagePickerContr.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        imagePickerContr.allowsEditing = true
        self.present(imagePickerContr, animated: true, completion: nil)
        
    }
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image Pick Cancelled")
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func getVidThumbNail(_ url: URL) -> (UIImage?){
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
            let thumbNailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
        
            return UIImage(cgImage: thumbNailCGImage)
        }
        catch let err {
            print(err)
        }
        return nil
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let videoName = NSUUID().uuidString
            
            let uploadTask = Storage.storage().reference().child("video_msgs").child(videoName).putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Error uploading video", error ?? "")
                    return
                }
                if let vidURL = metadata?.downloadURL()?.absoluteString {
                    
                    if let thumbImage = self.getVidThumbNail(videoURL) {
                        
                        
                        self.uploadImageMsg(thumbImage, mainRef: Storage.storage().reference().child("video_msgs").child("thumbnails"), completionHandler: { (imageURL) in
                            
                            if imageURL == "" {
                                return
                            }
                            let dict : [String:Any] = ["imgHght" : (thumbImage.size.height as NSNumber) , "imgWidth" : (thumbImage.size.width as NSNumber) , "msgImgURL" : imageURL , "msgVideoURL" : vidURL]
                            self.sendMsg2Firebase(dict)
                            
                        })
                        
                    }
                    
                }
                
            })
            
            uploadTask.observe(StorageTaskStatus.progress, handler: { (snapshot) in
                print(snapshot.progress?.completedUnitCount ?? "")
            })
            
            uploadTask.observe(StorageTaskStatus.success, handler: { (snapShot) in
                print("Success")
            })
            
        }
        else{
            var selectedImageFromPicker : UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            }
            else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker {
                
                uploadImageMsg(selectedImage, mainRef: Storage.storage().reference().child("message_images"), completionHandler: { (imageURL) in
                    if imageURL == "" {
                        return
                    }
                    let dict : [String:Any] = ["imgHght" : (selectedImage.size.height as NSNumber) , "imgWidth" : (selectedImage.size.width as NSNumber) , "msgImgURL" : imageURL]
                    self.sendMsg2Firebase(dict)
                })

            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    private func sendMsg2Firebase(_ customMsgDict : [String : Any]){
    
        
        let mainRef = Database.database().reference()
        let messages = mainRef.child("messages")
        
        let entryChild = messages.childByAutoId()
        
        let toID = user?.UID
        let fromID = Auth.auth().currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        var values = ["timestamp" : timestamp , "toID" : toID ?? "" , "fromID" : fromID ?? ""] as [String : Any]
        
        customMsgDict.forEach { (key,value) in
            values[key] = value
        }
        
        entryChild.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            let msgDB = mainRef.child("userMsgDB")
            let vals = [entryChild.key : 1]
            
            let userMSGDBRef = Database.database().reference().child("usrMsgHistory")
            
            msgDB.child(fromID!).child(toID!).updateChildValues(vals, withCompletionBlock: { (error, ref) in
                let histr = [toID! : entryChild.key]
                userMSGDBRef.child(fromID!).updateChildValues(histr)
            })
            
            msgDB.child(toID!).child(fromID!).updateChildValues(vals, withCompletionBlock: { (error, ref) in
                let histr = [fromID! : entryChild.key]
                userMSGDBRef.child(toID!).updateChildValues(histr)
            })
            
            
        })

        
    }
    
    func uploadImageMsg(_ selectedImage : UIImage! , mainRef : StorageReference! , completionHandler : @escaping (String) -> ()){
        let imageString = NSUUID().uuidString
        let ref = mainRef.child(imageString) //Storage.storage().reference().child("message_images")
        
        if let imageData = UIImageJPEGRepresentation(selectedImage, 0.2) {
            ref.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print("Error while sending image messages: ",error ?? "")
                    return
                }
                
                if let imageURL = metaData?.downloadURL()?.absoluteString {
                    
                    completionHandler(imageURL)
                    
                   // self.sendImageMsg(imageURL, imgHght: selectedImage.size.height, imgWidth: selectedImage.size.width)
                }
            })
        }
    }
    
    lazy var inputContainerView : UIView! = {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        containerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        self.msgTF = UITextField(frame: CGRect(x: 10, y: 8, width: 200, height: 34))
        self.msgTF.placeholder = "Type your message"
        self.msgTF.backgroundColor = UIColor.white
        self.msgTF.borderStyle = UITextBorderStyle.roundedRect
        self.msgTF.delegate = self
        
        self.sendBtn = UIButton(type: UIButtonType.custom)
        self.sendBtn.setTitle("Send", for: UIControlState.normal)
        self.sendBtn.addTarget(self, action: #selector(sendMsgAction), for: UIControlEvents.touchUpInside)
        self.sendBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        self.imageSendBtn = UIButton(type: UIButtonType.contactAdd)
        self.imageSendBtn.setTitle("", for: UIControlState.normal)
        self.imageSendBtn.addTarget(self, action: #selector(sendImageAction), for: UIControlEvents.touchUpInside)
        self.imageSendBtn.tintColor = UIColor.gray
       // self.imageSendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        
        containerView.addSubview(self.sendBtn)
        containerView.addSubview(self.msgTF)
        containerView.addSubview(self.imageSendBtn)
        
        self.sendBtn.translatesAutoresizingMaskIntoConstraints = false
        self.msgTF.translatesAutoresizingMaskIntoConstraints = false
        self.imageSendBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.sendBtn.setContentCompressionResistancePriority(UILayoutPriority(exactly: 751)!, for: UILayoutConstraintAxis.horizontal)
        
        self.msgTF.setContentHuggingPriority(UILayoutPriority(exactly: 249)!, for:
            UILayoutConstraintAxis.horizontal)
        
        containerView.addConstraint(NSLayoutConstraint(item: self.imageSendBtn, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        
        containerView.addConstraint(NSLayoutConstraint(item: self.imageSendBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 44.0))
        
        containerView.addConstraint(NSLayoutConstraint(item: self.imageSendBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 44.0))
        
        containerView.addConstraint(NSLayoutConstraint(item: self.imageSendBtn, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 2.0))
        
        
        containerView.addConstraint(NSLayoutConstraint(item: self.msgTF, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.imageSendBtn, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 2.0))
        
        containerView.addConstraint(NSLayoutConstraint(item: self.msgTF, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: self.msgTF, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: -16.0))
        
        
        containerView.addConstraint(NSLayoutConstraint(item: self.sendBtn, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: self.sendBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: self.sendBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -8.0))

        containerView.addConstraint(NSLayoutConstraint(item: self.msgTF, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.sendBtn, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: -10.0))
        
        return containerView
    }() //Closures
   
    override var inputAccessoryView: UIView?{
        
        get{
            
            return inputContainerView
            
        }
        
    }
    
    
    override var canBecomeFirstResponder: Bool{
        get{
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.removeFromSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveTableUp), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveTableDown), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func moveTableUp(notification:NSNotification){
        
        if(self.messages.count > 0){
            
            let kbFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let kbRect = kbFrame.cgRectValue
            
            self.tableViewBottomContraint.constant = kbRect.height + 5
            self.view.layoutIfNeeded()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func moveTableDown(){
        
        if(self.messages.count > 0){
            self.tableViewBottomContraint.constant = 50
            self.view.layoutIfNeeded()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsgAction(sendBtn)
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = self.messages[indexPath.row]
        
        if let imgHght = msg.imgHght , let imgWidth = msg.imgWidth {
            return CGFloat(((imgHght.floatValue / imgWidth.floatValue) * Float(tableView.frame.size.width * 0.65)) + 10)
        }
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
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        if self.isMovingFromParentViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    var normalImgRect: CGRect?
    var zoomingImgView : UIImageView!
    var zoomBGView: UIView!
    
    @IBAction func zoomAction(_ sender: UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        normalImgRect = imgView.superview?.convert(imgView.frame, to: nil)
        
        zoomingImgView = UIImageView(frame: normalImgRect!)
        zoomingImgView.image = imgView.image
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(zoomOutAction))
        gesture.numberOfTapsRequired = 1
        zoomingImgView.isUserInteractionEnabled = true
        zoomingImgView.addGestureRecognizer(gesture)
        
        if let keyWindow = UIApplication.shared.keyWindow {
        
            self.inputAccessoryView?.alpha = 0
            
            zoomBGView = UIView(frame: keyWindow.frame)
            zoomBGView.backgroundColor = UIColor(white: 0, alpha: 0.85)
            zoomBGView.alpha = 0
            
            let gesture1 = UITapGestureRecognizer(target: self, action: #selector(zoomOutAction))
            gesture1.numberOfTapsRequired = 1
            zoomBGView.isUserInteractionEnabled = true
            zoomBGView.addGestureRecognizer(gesture1)
            
            keyWindow.addSubview(zoomBGView)
            keyWindow.addSubview(zoomingImgView)
            
            let newHght = (((normalImgRect?.size.height)! / (normalImgRect?.size.width)!) * keyWindow.frame.size.width)
            
            let zoomedImgRect = CGRect(x: 0, y: 0, width: keyWindow.frame.size.width, height: newHght)
            
            UIView.animate(withDuration: 0.34, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.zoomingImgView.frame = zoomedImgRect
                self.zoomingImgView.center = keyWindow.center
                
                self.zoomBGView.alpha = 1
            }, completion: nil)
        }
        
    }
    
    @IBAction func zoomOutAction(_ sender: UITapGestureRecognizer) {
       
        UIView.animate(withDuration: 0.34, delay: 0, options: .curveEaseOut, animations: {
            self.zoomingImgView.frame = self.normalImgRect!
            
            self.zoomBGView.alpha = 0
            
        }) { (finished) in
            
            self.inputAccessoryView?.alpha = 1
            self.zoomingImgView.removeFromSuperview()
            self.zoomBGView.removeFromSuperview()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let customCell = cell as? BubbleCell{
            
            if customCell.player != nil {
                customCell.player?.pause()
                customCell.playerLayer?.removeFromSuperlayer()
                customCell.player = nil
            }
            
        }
        
    }
    
    
}
