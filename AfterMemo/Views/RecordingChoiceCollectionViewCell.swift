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
        
        
        self.layer.cornerRadius = 5
        //self.choiceImage.layer.masksToBounds = true
        //self.choiceImage.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       // self.setCircularImageView()
        self.choiceImage.contentMode = .scaleAspectFit
        self.choiceImage.clipsToBounds = true
        self.choiceImage.layer.cornerRadius = 5.0
        self.choiceImage.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: 200, height: 140))
    }
    
    
    
    func setCircularImageView() {
        self.choiceImage.layer.cornerRadius = CGFloat(roundf(Float(self.choiceImage.frame.size.width / 2.0)))
        
        self.choiceImage.layer.borderWidth = 2.0
//        self.choiceImage.layer.borderColor = UIColor.white.cgColor
    }
    
    
    
    
    
    
    
}

extension UIImageView {
    func addBlackGradientLayer(frame: CGRect){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        
        gradient.colors = [UIColor.clear.cgColor,UIColor.darkGray.cgColor]
        gradient.locations = [0.0, 1.3]
        self.layer.addSublayer(gradient)
    }

}
