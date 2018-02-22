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
    
    var playBtn : UIButton!
    var loadingView : UIActivityIndicatorView!
    
    var videoURL : String!
    
    var msgType : MessageContentType = .normal
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    var playerItem : AVPlayerItem?
    
    var normalImgRect: CGRect?
    var zoomingImgView : UIImageView!
    var zoomBGView: UIView!
    var presentingController: UIViewController!
    
    var imageURL : String!
    
    func playVideo(){
        
        if videoURL != nil , let url = URL(string: videoURL){
            
            playerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(bufferedVideo), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
            
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            
            player = AVPlayer(playerItem: playerItem)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = zoomingImgView.bounds
            
            zoomingImgView.layer.addSublayer(playerLayer!)
            
            player?.play()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
    
    func finishedVideo(_ notification : Notification!){
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
        playBtn.setTitle(Constants.playIconText, for: .normal)
        loadingView.stopAnimating()
        playBtn.tag = 2
    }
    func bufferedVideo(_ notification : Notification!){
//        let playerItem = notification.object as! AVPlayerItem
//        playerItem.seek(to: kCMTimeZero)
        
        print("Buffered")
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let keyPath = keyPath {
                switch keyPath {
                case "playbackBufferEmpty":
                    // Show loader
                    playBtn.setTitle("", for: .normal)
                    loadingView.startAnimating()
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    if playBtn.tag != 2 {
                        playBtn.setTitle("", for: .normal)
                        loadingView.stopAnimating()
                    }
                case "playbackBufferFull":
                    // Hide loader
                    if playBtn.tag != 2 {
                        playBtn.setTitle("", for: .normal)
                        loadingView.stopAnimating()
                    }
                default:
                    print(keyPath)
                }
            }
        }
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
                toIDImage.tag = self.tag 
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
            msgType = .videomsg
            self.videoURL = vidURL
            playLabel.text = Constants.playIconText
        }
        
    }
    
    
    @IBAction func zoomAction(_ sender: UITapGestureRecognizer) {
        
        if let presentingVC = presentingController as? ChatMessagesController {
            presentingVC.msgTF.resignFirstResponder()
        }
        
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
       
            if msgType == .imagemsg {
                let gesture = UITapGestureRecognizer(target: self, action: #selector(zoomOutAction))
                gesture.numberOfTapsRequired = 1
                zoomingImgView.isUserInteractionEnabled = true
                zoomingImgView.addGestureRecognizer(gesture)
            }
            
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
                }, completion: { (finished) in
                    if self.msgType == .videomsg {
                        self.addVideoControlButtons()
                    }
                })
        
            }
        }
    }
    
    @objc @IBAction func videoTappedAction(_ sender : UIButton) {
        if sender.tag == 1 {
            if !loadingView.isAnimating {
                playBtn.setTitle(Constants.playIconText, for: .normal)
            }
//            loadingView.stopAnimating()
            player?.pause()
            sender.tag = 2
        }
        else {
            playBtn.setTitle("", for: .normal)
//            loadingView.startAnimating()
            player?.play()
            sender.tag = 1
        }
    }
    
    func addVideoControlButtons(){
        if let keyWindow = UIApplication.shared.keyWindow {
            playBtn = UIButton(frame: self.zoomingImgView.frame)
            playBtn.titleLabel?.font = UIFont(name: "fontello", size: 70)
            playBtn.setTitle("", for: .normal)
            playBtn.setTitleColor(UIColor.white, for: .normal)
            playBtn.tag = 1
            playBtn.addTarget(self, action: #selector(videoTappedAction(_:)), for: .touchUpInside)
            
            loadingView = UIActivityIndicatorView(frame: self.zoomingImgView.frame)
            loadingView.activityIndicatorViewStyle = .whiteLarge
            loadingView.hidesWhenStopped = true
            loadingView.startAnimating()
            
            if zoomBGView != nil {
                keyWindow.addSubview(loadingView)
                keyWindow.addSubview(playBtn)
                self.playVideo()
            }
        }
    }
    
    
    @IBAction func zoomOutAction(_ sender: UITapGestureRecognizer) {
        
        if msgType == .videomsg {
            playBtn.isHidden = true
            loadingView.isHidden = true
            
            NotificationCenter.default.removeObserver(self)
            
            playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
            
            player?.pause()
            playerLayer?.removeFromSuperlayer()
        }
        
        UIView.animate(withDuration: 0.34, delay: 0, options: .curveEaseOut, animations: {
            self.zoomingImgView.frame = self.normalImgRect!
            
            self.zoomBGView.alpha = 0
            
        }) { (finished) in
            
            self.presentingController.view.isUserInteractionEnabled = true
            
            self.inputAccessoryView?.alpha = 1
            self.zoomingImgView.removeFromSuperview()
            self.zoomBGView.removeFromSuperview()
            
            if self.playBtn != nil {
                self.playBtn.removeFromSuperview()
                self.playBtn = nil
            }
            if self.loadingView != nil {
                self.loadingView.removeFromSuperview()
                self.loadingView = nil
            }

        }
        
    }
    
    
}

