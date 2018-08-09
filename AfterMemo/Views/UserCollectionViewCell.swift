//
//  UserCollectionViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/18/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var propertiesButton: UIButton!
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoImage.contentMode = .scaleAspectFill
        self.videoImage.clipsToBounds = true
    }
    
    
    
    
    
    var isEditing: Bool = false {
        didSet{
            selectionImage.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet{
            if isEditing {
                selectionImage.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
            }
        }
    }
    
    
}
