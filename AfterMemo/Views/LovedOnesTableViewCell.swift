//
//  LovedOnesTableViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/28/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class LovedOnesTableViewCell: UITableViewCell {
   
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.black.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
