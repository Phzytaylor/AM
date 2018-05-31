//
//  SelectionCollectionViewCell.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/27/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents

class SelectionCollectionViewCell: MDCCardCollectionCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //TODO: Configure the cell properties
        self.backgroundColor = .white
        
        //TODO: Configure the MDCCardCollectionCell specific properties
        self.cornerRadius = 4.0;
        self.setBorderWidth(1.0, for:.normal)
        self.setBorderColor(.lightGray, for: .normal)
    }
}
