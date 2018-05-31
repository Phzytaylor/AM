//
//  RecordingChoiceCollectionViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/23/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class RecordingChoiceCollectionViewCell: UICollectionViewCell {
//    var recordingChoiceCollectionViewController: RecordingChoiceCollectionViewController?
    @IBOutlet weak var choiceImage: UIImageView!
    
    @IBOutlet weak var memoChoiceLabel: UILabel!
    
    override var bounds: CGRect {
        didSet{
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.choiceImage.layer.masksToBounds = true
        //self.choiceImage.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setCircularImageView()
    }
    
    
    
    func setCircularImageView() {
        self.choiceImage.layer.cornerRadius = CGFloat(roundf(Float(self.choiceImage.frame.size.width / 2.0)))
    }
    
    
    
    
    
    
    
}
