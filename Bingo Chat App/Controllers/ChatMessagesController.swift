//
//  ChatMessagesController.swift
//  Bingo Chat App
//
//  Created by Prateek Sharma on 19/02/18.
//  Copyright © 2018 14K. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatMessagesController: UIViewController {

    var messages = [Message]()
    var messagesKeys = [String]()
    
    var keyboardHght : CGFloat!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sendBtn: UIButton!
    var imageSendBtn: UIButton!
    var msgTF: UITextField!

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
            
            fetchAllMessages()
        }
        
    }
    
    
    let imagePickerController : UIImagePickerController! = {
        let imagePickerContr = UIImagePickerController()
        
        imagePickerContr.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imagePickerContr.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        imagePickerContr.allowsEditing = true
        return imagePickerContr
    }()
    
    
    func getMessagesForKeys(keyCollection : [String]) {
        let ref = Database.database().reference().child("messages")
        
        let count = keyCollection.count
        
        if count == 0 {
            self.observeNewMessages()
            return
        }
        
        for key in keyCollection {
            ref.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let msgDict = snapshot.value as? [String:Any]{
                    
                    self.messagesKeys.append(key)
                    
                    let message = Message()
                    message.setValuesForKeys(msgDict)
                    
                    self.messages.append(message)
                    
                }
                
                if count == self.messages.count {
                    self.messages.sort(by: { (msg1, msg2) -> Bool in
                        return (msg1.timestamp?.doubleValue)! < (msg2.timestamp?.doubleValue)!
                    })
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.collectionView.setNeedsLayout()
                        self.collectionView.layoutIfNeeded()
                        if count > 0 {
                                self.collectionView.scrollToItem(at: IndexPath(row: (count - 1), section: 0), at: UICollectionViewScrollPosition.bottom, animated: true)
                        }
                    }
                    self.observeNewMessages()
                }
                
            })
        }
        
    }
    
    func fetchAllMessages(){
        
        if let myselfUser = Auth.auth().currentUser {
            let uid = myselfUser.uid
            
            let msgsDBRef = Database.database().reference().child("userMsgDB").child(uid).child((user?.UID!)!)
            
            msgsDBRef.observeSingleEvent(of: .value, with: { (snapShot) in
                
                if snapShot.exists() {
                    if let msgKeysCollection = snapShot.value as? [String : Any] {
                        
                        var msgsKeys = [String]()
                        
                        for (key,_) in msgKeysCollection {
                            if key != "" {
                                msgsKeys.append(key)
                            }
                        }
                        
                        self.getMessagesForKeys(keyCollection : msgsKeys)
                    }
                }
                else{
                    self.observeNewMessages()
                }
                
            })
            
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
    
    func estimatedFrameForText(_ text : String) -> CGRect{
        let size = CGSize(width: (self.collectionView.frame.width * 0.7), height: 1000)
        return NSString(string: text).boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin , .usesFontLeading], attributes: [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 15)!], context: nil)
    }
    
    
    func observeNewMessages(){
        
        let ref = Database.database().reference().child("messages")
        if let currentAppUser = Auth.auth().currentUser , let user = user {
            let msgsDBRef = Database.database().reference().child("userMsgDB").child(currentAppUser.uid).child((user.UID!))
            
            msgsDBRef.observe(.childAdded, with: { (snapShot) in
                
                if (snapShot.key != "" ){
                    
                    if !self.messagesKeys.contains(snapShot.key) {
                        
                        ref.child(snapShot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let msgDict = snapshot.value as? [String:Any]{
                                
                                let message = Message()
                                message.setValuesForKeys(msgDict)
                                
                                self.messages.append(message)
                                let msgsCnt = self.messages.count
                                
                                var shouldReloadAll = false
                                
                                if msgsCnt > 1 {
                                    let msg2 = self.messages[msgsCnt - 1]
                                    let msg1 = self.messages[msgsCnt - 2]
                                    
                                    if (msg1.timestamp?.doubleValue)! > (msg2.timestamp?.doubleValue)! {
                                        shouldReloadAll = true
                                        self.messages.sort(by: { (msg1, msg2) -> Bool in
                                            return (msg1.timestamp?.doubleValue)! < (msg2.timestamp?.doubleValue)!
                                        })
                                    }
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    if shouldReloadAll {
                                        self.collectionView.reloadData()
                                    }
                                    else{
                                        if msgsCnt > 1 {
                                            self.collectionView.insertItems(at: [IndexPath(row: msgsCnt-1, section: 0)])
                                            self.collectionView.reloadItems(at: [IndexPath(row: msgsCnt-2, section: 0)])
                                            self.collectionView.setNeedsLayout()
                                            self.collectionView.layoutIfNeeded()
                                        }
                                    }
                                    if msgsCnt > 0 {
                                        self.collectionView.scrollToItem(at: IndexPath(row: msgsCnt-1, section: 0), at: .bottom, animated: true)
                                    }
                                }
                            }
                            
                        }, withCancel: nil)
                        
                    }
                    
                }
                
            }, withCancel: nil)
            
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
    
    func sendMsg2Firebase(_ customMsgDict : [String : Any]){
        
        
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
    

}


extension ChatMessagesController {
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardHght = nil
        imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        if self.isMovingFromParentViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveTableUp), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveTableDown), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        if msgTF != nil {
            if msgTF.isEditing {
                if keyboardHght == nil {
                    msgTF.resignFirstResponder()
                    msgTF.becomeFirstResponder()
                }
                else{
                    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: keyboardHght - 50 + 10, right: 0)
                    self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHght - 50, right: 0)
                    self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
                }
            }
        }
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
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func moveTableUp(notification:NSNotification){
        
        if(self.messages.count > 0){
            
            let kbFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let kbRect = kbFrame.cgRectValue
            
            if kbRect.height > 120 {
                
                keyboardHght = kbRect.height
                
                self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kbRect.height - 50 + 10, right: 0)
                self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbRect.height - 50, right: 0)
                UIView.animate(withDuration: 0.1, animations: {
                    self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: false)
                }, completion: { (finished) in
                    
                })
            }
            
        }
    }
    
    func moveTableDown(){
        
        if(self.messages.count > 0){
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                self.collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
            })
        }
    }
    
}


extension ChatMessagesController : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let customCell = cell as? BubbleCell{
//
//            if customCell.player != nil {
//                customCell.player?.pause()
//                customCell.playerLayer?.removeFromSuperlayer()
//                customCell.player = nil
//            }
//
//        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let msg = messages[indexPath.row]
        var cellID : String! = "MessageCell"

        var myUID = ""
        if let currentUser = Auth.auth().currentUser {
            myUID = currentUser.uid
        }

        var pref : String
        let messageSenderUID = msg.fromID!
        var toIDImageURL : String? = nil
        
        if(messageSenderUID == myUID){
            pref = "sent"
        }
        else{
            pref = "recieved"
            if let sender = user {
                toIDImageURL = sender.profileImageUrl
            }
        }

        if (indexPath.row <= 0) || (messages[indexPath.row - 1].fromID != messageSenderUID) {
            pref = "\(pref)Up"
        }
        
        if (indexPath.row >= (messages.count - 1)) || (messages[indexPath.row + 1].fromID != messageSenderUID) {
            pref = "\(pref)Down"
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

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BubbleCollectionViewCell
        cell.tag = indexPath.row
        cell.setupCell(msg, sendersImageURL: toIDImageURL)
        cell.addActionGestures(presentingController : self)
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let bubbleCell = cell as? BubbleCell {
//            bubbleCell.makeRoundCellCorners()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let msg = self.messages[indexPath.row]
        var verticalPadding : CGFloat = 1
        
        let messageSenderUID = msg.fromID!
        if (indexPath.row <= 0) || (messages[indexPath.row - 1].fromID != messageSenderUID) {
            verticalPadding = verticalPadding + 4.5
        }
        if (indexPath.row >= (messages.count - 1)) || (messages[indexPath.row + 1].fromID != messageSenderUID) {
            verticalPadding = verticalPadding + 4.5
        }
        
        if let imgHght = msg.imgHght , let imgWidth = msg.imgWidth {
            return CGSize(width: collectionView.frame.size.width, height: CGFloat(((imgHght.floatValue / imgWidth.floatValue) * Float(collectionView.frame.size.width * 0.7))) + verticalPadding)
        }
        else if let msgText = msg.msg{
            let frameSize = estimatedFrameForText(msgText)
            return CGSize(width: collectionView.frame.size.width, height: frameSize.height + 14 + 13 + verticalPadding)
        }
        
        return CGSize(width: collectionView.frame.size.width, height: 1)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }
    
    
}

extension ChatMessagesController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
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
    
    
}

extension ChatMessagesController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMsgAction(sendBtn)
        return true
    }
    
}

extension ChatMessagesController : UIScrollViewDelegate {
    
    
    
}
