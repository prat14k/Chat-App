//
//  BubbleCell.swift
//  Bingo Chat App
//
//  Created by Prateek on 07/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import AVFoundation

class BubbleCell: UITableViewCell {
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var toIDImage: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var videoURL : String!
    
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
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
                
                playButton.isHidden = true
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
        self.playButton.isHidden = false
        
    }
    
    
    func setupCell(_ msg : Message!){
        
        if let msgText = msg.msg {
            msgLabel.text = msgText
        }
        else if let imgUrl = msg.msgImgURL{
            msgImageView.loadImageUsingURLString(imgUrl)
        }
        
        if let vidURL = msg.msgVideoURL {
            playButton.isHidden = false
            
            self.videoURL = vidURL
            self.playButton.addTarget(self, action: #selector(playVideo), for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
}
