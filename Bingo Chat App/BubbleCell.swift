//
//  BubbleCell.swift
//  Bingo Chat App
//
//  Created by Prateek on 07/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit
import AVFoundation

//enum MessageType {
//    case normal
//    case imagemsg
//    case videomsg
//}

class BubbleCell: UITableViewCell {
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var toIDImage: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var roundCorners : UIRectCorner = []
    var maskingImageName : String!
    
    var videoURL : String!
    
    var msgType : MessageContentType = .normal
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeRoundCellCorners()
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
    
    
    func setupCell(_ msg : Message! , sendersImageURL : String? , withRoundCorners corners : UIRectCorner , maskingImageName : String){
    
        if toIDImage != nil {
            if let imageUrl = sendersImageURL {
                toIDImage.loadImageUsingURLString(imageUrl)
            }
            toIDImage.layer.cornerRadius = 10
            toIDImage.layer.masksToBounds = true
        }
        
        if let msgText = msg.msg {
            msgLabel.text = msgText
            msgType = .normal
        }
        else if let imgUrl = msg.msgImgURL{
            msgImageView.loadImageUsingURLString(imgUrl)
            msgType = .imagemsg
        }
        
        if let vidURL = msg.msgVideoURL {
            playButton.isHidden = false
            msgType = .videomsg
            self.videoURL = vidURL
            self.playButton.addTarget(self, action: #selector(playVideo), for: UIControlEvents.touchUpInside)
            
        }
        
        self.maskingImageName = maskingImageName
//        makeRoundCellCorners(corners)
        roundCorners = corners
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func makeRoundCellCorners() {
        
        
//        var view : UIView
//
//        switch msgType {
//        case .normal:
//            view = containerView
//        default :
//            return
////            view = msgImageView
//        }
//
//        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: roundCorners, cornerRadii: CGSize(width: 0, height: 0))
//        let shape = CAShapeLayer()
//        shape.path = maskPath.cgPath
//        self.layer.mask = shape
        
    }
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
}
