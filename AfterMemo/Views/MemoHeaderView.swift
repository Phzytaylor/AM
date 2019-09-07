//
//  MemoHeaderView.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/31/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
class MemoHeaderView: UIView {

    struct Constants {
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static let minHeight: CGFloat = statusBarHeight + 55
    static let maxHeight: CGFloat = 100.00
}
    
    
    
    //MARK: Properties
    
    let imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Transparent BG"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 75.0).isActive = true
        
//        imageView.frame = CGRect(x: 155, y: 30, width: 70, height: 70)
        
        
        //imageView.backgroundColor = .red
        return imageView
    }()
    
    var imageViewCenterCon: NSLayoutConstraint?
    var imageViewYCon: NSLayoutConstraint?
    
    let secondImageView: UIImageView = {
        let imageView = UIImageView(image:#imageLiteral(resourceName: "iStock-174765643 (2)"))
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
//        label.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "AM Big Logo"))
//        label.textAlignment = .center
//        label.textColor = .white
//        label.shadowOffset = CGSize(width: 1, height: 1)
//        label.shadowColor = .darkGray
        return label
    }()
    
    //MARK: Init
    
     init() {
        super.init(frame: .zero)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(){
        backgroundColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0);

        addSubview(secondImageView)
        addSubview(imageView)
    }
    
    func update(withScrollPhasePercentage scrollPhasePercentage: CGFloat) {
        // 1
        let imageAlpha = min(scrollPhasePercentage.scaled(from: 0...0.8, to: 0...1), 1.0)
        imageView.alpha = imageAlpha
        
//        let fontSize = scrollPhasePercentage.scaled(from: 0...1, to: 22.0...60.0)
//        let font = UIFont(name: "CourierNewPS-BoldMT", size: fontSize)
//        titleLabel.font = font
//
    }


}

// MARK: Number Utilities - Based on code from https://github.com/raizlabs/swiftilities
extension FloatingPoint {
    
    public func scaled(from source: ClosedRange<Self>, to destination: ClosedRange<Self>, clamped: Bool = false, reversed: Bool = false) -> Self {
        let destinationStart = reversed ? destination.upperBound : destination.lowerBound
        let destinationEnd = reversed ? destination.lowerBound : destination.upperBound
        
        // these are broken up to speed up compile time
        let selfMinusLower = self - source.lowerBound
        let sourceUpperMinusLower = source.upperBound - source.lowerBound
        let destinationUpperMinusLower = destinationEnd - destinationStart
        var result = (selfMinusLower / sourceUpperMinusLower) * destinationUpperMinusLower + destinationStart
        if clamped {
            result = result.clamped(to: destination)
        }
        return result
    }
    
}

public extension Comparable {
    
    func clamped(to range: ClosedRange<Self>) -> Self {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
    
    func clamped(min lower: Self, max upper: Self) -> Self {
        return min(max(self, lower), upper)
    }
    
}
