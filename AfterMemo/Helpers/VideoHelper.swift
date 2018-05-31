//
//  VideoHelper.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/19/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class VideoHelper {
    
    static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerControllerSourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
       delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    
}

