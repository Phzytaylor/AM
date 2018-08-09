//
//  ContactLovedOneTableViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/6/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class ContactLovedOneTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contactImage.layer.masksToBounds = false
        contactImage.layer.cornerRadius = contactImage.frame.height/2
        contactImage.layer.borderColor = UIColor.black.cgColor
        contactImage.layer.borderWidth = 2.0
        contactImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
