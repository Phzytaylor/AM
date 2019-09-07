//
//  RemindersCollectionViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/18/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class RemindersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backingView: UIView!
    
    @IBOutlet weak var reminderCell: RemindersCollectionViewCell!
    
    @IBOutlet weak var reminderLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        // Initialization code
        backingView.layer.cornerRadius = 10.0
        backingView.clipsToBounds = true
        
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.1764705882, green: 0.4078431373, blue: 0.5254901961, alpha: 1).cgColor, UIColor.black.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.frame = self.backingView.bounds
        self.backingView.layer.addSublayer(layer)
        
        self.backingView.bringSubviewToFront(self.reminderLabel)
        self.reminderLabel.textColor = .white
        self.reminderLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
       

}
}
