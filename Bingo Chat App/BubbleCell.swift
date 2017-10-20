//
//  BubbleCell.swift
//  Bingo Chat App
//
//  Created by Prateek on 07/10/17.
//  Copyright © 2017 14K. All rights reserved.
//

import UIKit

class BubbleCell: UITableViewCell {
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var toIDImage: UIImageView!
    
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var msgImageHieghtContraint: NSLayoutConstraint!
}
