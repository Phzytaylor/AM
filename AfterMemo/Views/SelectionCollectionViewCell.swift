//
//  SelectionCollectionViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/27/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents

protocol SelectionDelegate: class {
    func editLovedOnePressed(_ cell:SelectionCollectionViewCell)
}

class SelectionCollectionViewCell: MDCCardCollectionCell {
   
    weak var delegate: SelectionDelegate?
    
    @IBOutlet weak var backingView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var triggersImage: UIImageView!
    @IBOutlet weak var videoMemoImage: UIImageView!
    
    @IBOutlet weak var writtenMemoImage: UIImageView!
    @IBOutlet weak var audioMemoImage: UIImageView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var triggerCount: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var videoCount: UILabel!
    @IBOutlet weak var audioCount: UILabel!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    
    @IBAction func editLovedOneAction(_ sender: UIButton) {
        delegate?.editLovedOnePressed(self)
        
        
        
    }
    @IBOutlet weak var editLovedOne: UIButton!
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var shadowLayer: CAShapeLayer!
   
    private var fillColor: UIColor = .blue // the color applied to the shadowLayer, rather than the view's backgroundColor
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.textColor = .black
        
//        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2
        userAvatarImageView.layer.cornerRadius = 10.0
      userAvatarImageView.clipsToBounds = true
     
        containerView.layer.addShadow()
        containerView.layer.roundCorners(radius: 10.0)
        
        userAvatarImageView.contentMode = .scaleAspectFill
        userAvatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        userAvatarImageView.layer.borderWidth = 1.0
      
        
       
        
        videoMemoImage.clipsToBounds = true
        audioMemoImage.clipsToBounds = true
        audioMemoImage.contentMode = .scaleAspectFill
        videoMemoImage.clipsToBounds = true
        writtenMemoImage.clipsToBounds = true
        
       
        
        backingView.layer.cornerRadius = 10.0
        backingView.clipsToBounds = true
        
      
        
//        self.backgroundColor = .clear
        
//        self.addSubview(seperatorView)
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : seperatorView]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : seperatorView]))
        
        //TODO: Configure the cell properties
//        self.backgroundColor = .white
        
        
        
        //TODO: Configure the MDCCardCollectionCell specific properties
        
    }
    
    
}


extension CALayer {
    
    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
//            if let sublayer = sublayers?.first,
//                sublayer.name == Constants.contentLayerName {
//
//                sublayer.removeFromSuperlayer()
//            }
            let contentLayer = CALayer()
            contentLayer.name = "tree"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
    func addShadow() {
        self.shadowOffset = CGSize(width: 5, height: 10)
        self.shadowOpacity = 0.7
        self.shadowRadius = 4.0
        self.shadowColor = UIColor.black.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
}

