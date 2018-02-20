//
//  BubbleCollectionViewCell.swift
//  Bingo Chat App
//
//  Created by Prateek Sharma on 20/02/18.
//  Copyright © 2018 14K. All rights reserved.
//

import UIKit
import AVFoundation

enum MessageSameNeighbourType {
    case none
    case top
    case bottom
    case both
}

enum MessageContentType {
    case normal
    case imagemsg
    case videomsg
}


class BubbleCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var toIDImage: UIImageView!
    
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView! {
        didSet {
            msgImageView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var videoURL : String!
    
    var msgType : MessageContentType = .normal
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    var normalImgRect: CGRect?
    var zoomingImgView : UIImageView!
    var zoomBGView: UIView!
    var presentingController: UIViewController!
    
    var imageURL : String!
    
    func playVideo(){
        
        if videoURL != nil , let url = URL(string: videoURL){
            
            let playerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            
            //            if(player != nil){
            //
            //                if(player?.error != nil){
            //                    return
            //                }
            //
            //                if (player?.rate != 0) {
            //                    playButton.isHidden = false
            //                    player?.pause()
            //                }
            //                else{
            //                    playButton.isHidden = true
            //                    player?.play()
            //                }
            //            }
            //            else
            // {
            player = AVPlayer(playerItem: playerItem)
            
//            playButton.isHidden = true
            activityLoader.startAnimating()
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = containerView.bounds
            
            containerView.layer.addSublayer(playerLayer!)
            
            player?.play()
            //}
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NotificationCenter.default.removeObserver(self)
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    func finishedVideo(_ notification : Notification!){
        
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
        
        self.activityLoader.stopAnimating()
//        self.playButton.isHidden = false
        
    }
    
    
    func addActionGestures(presentingController : UIViewController) {
        if imageURL != nil {
            self.presentingController = presentingController
            self.presentingController.view.endEditing(true)
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(zoomAction))
            gesture.numberOfTapsRequired = 1
            msgImageView.addGestureRecognizer(gesture)
        }
    }
    
    
    func setupCell(_ msg : Message! , sendersImageURL : String?){
        
        if toIDImage != nil {
            if let imageUrl = sendersImageURL {
                toIDImage.loadImageUsingURLString(imageUrl)
            }
        }
        
        if let msgText = msg.msg {
            messageTextView.textContainer.lineFragmentPadding = 0
            messageTextView.textContainerInset = UIEdgeInsets.zero
            messageTextView.text = msgText
            msgType = .normal
        }
        else if let imgUrl = msg.msgImgURL{
            self.imageURL = imgUrl
            msgImageView.loadImageUsingURLString(imgUrl,isToBeCircled: false)
            msgType = .imagemsg
        }
        
        if let vidURL = msg.msgVideoURL {
//            playButton.isHidden = false
            msgType = .videomsg
            self.videoURL = vidURL
            playLabel.text = Constants.playIconText
//            self.playButton.addTarget(self, action: #selector(playVideo), for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    
    @IBAction func zoomAction(_ sender: UITapGestureRecognizer) {
        
        if let gestureTriggeringView = sender.view {
            normalImgRect = gestureTriggeringView.superview?.convert(gestureTriggeringView.frame, to: nil)
            
            zoomingImgView = UIImageView(frame: normalImgRect!)
            if let imgView = gestureTriggeringView as? UIImageView {
                zoomingImgView.image = imgView.image
            }
            else{
                if imageURL == nil {
                    return
                }
                zoomingImgView.loadImageUsingURLString(imageURL, isToBeCircled: false)
            }
       
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
                
                self.presentingController.view.isUserInteractionEnabled = false
                
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
    }
    
    @IBAction func zoomOutAction(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.34, delay: 0, options: .curveEaseOut, animations: {
            self.zoomingImgView.frame = self.normalImgRect!
            
            self.zoomBGView.alpha = 0
            
        }) { (finished) in
            
            self.presentingController.view.isUserInteractionEnabled = true
            
            self.inputAccessoryView?.alpha = 1
            self.zoomingImgView.removeFromSuperview()
            self.zoomBGView.removeFromSuperview()
        }
        
    }
    
    
}

