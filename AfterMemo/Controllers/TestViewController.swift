//
//  TestViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/19/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TestViewController: AVPlayerViewController {

    var passedURL: String?
    var passedAudioURL: String?
    var audio: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let url = passedURL else {
            return
        }
        guard let audioURL = passedAudioURL else {return}
        
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        
        
        if audio == false {
            let dataPath = documentsDirectory.appendingPathComponent(url)
            
            let videoURL = URL(string: dataPath.absoluteString)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
            
        } else if audio == true {
            let dataPath = documentsDirectory.appendingPathComponent(audioURL)
            
            guard let playerURL = URL(string: dataPath.absoluteString) else {return}
            let player = AVPlayer(url: playerURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
