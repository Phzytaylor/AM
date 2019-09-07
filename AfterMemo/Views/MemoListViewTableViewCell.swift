//
//  MemoListViewTableViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 8/29/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class MemoListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var releaseTimeLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var memoImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var audioProgress: UIProgressView!
    @IBOutlet weak var propertiesButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        memoImage.contentMode = .scaleAspectFill
        memoImage.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
