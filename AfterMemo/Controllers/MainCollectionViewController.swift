//
//  MainCollectionViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/17/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit
import MobileCoreServices


private let reuseIdentifier = "memo"

class MainCollectionViewController: UICollectionViewController {
    
    @IBAction func updateInfoAction(_ sender: UIButton) {

        guard let cell = sender.superview?.superview as? UserCollectionViewCell else {
            
            print("I failed big time")
            return
        }
        guard  let indexPath = collectionView?.indexPath(for: cell) else {
            return
        }
        

        print(" I am: \(indexPath.row)")
        
    }
   
    
    

    // MARK: - Properties
    var fileName = ""
    var audioPlayer: AVAudioPlayer?
    var passedRecipient: Recipient?
    var videosArray: [NSManagedObject] = []
    var voiceMemosArray: [NSManagedObject] = []
    
    var combinedArray: [NSManagedObject] = []
    
 
    // MARK: - TODO
    //Make sure to pass the selected person then do a coredata fetch request and load their memos.
    
    
    

//    var tempArray = ["1 Video", "2 Videos","More stuff", "testing things","1 Video", "2 Videos","More stuff", "testing things"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 20) / 2
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width:width, height:width)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
      
        
        
//        let videosFetch: NSFetchRequest<Videos> = Videos.fetchRequest()
//        let audioMemosFetch: NSFetchRequest<VoiceMemos> = VoiceMemos.fetchRequest()
//
//        do {
//            videosArray = try managedContext.fetch(videosFetch)
//            voiceMemosArray = try managedContext.fetch(audioMemosFetch)
//
//            if videosArray.count > 0 {
//                for element in videosArray {
//                    combinedArray.append(element)
//                }
//            }
//            if voiceMemosArray.count > 0 {
//                for element in voiceMemosArray {
//                    combinedArray.append(element)
//                }
//
//            }
//
//        } catch let error as NSError {
//            print("Could not find videos: \(error), \(error.userInfo)")
//        }
        
       
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "playVideo" {
            
            guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                return
            }
            
            let filePathItem = combinedArray[indexPath.row]
            
            let filePath = filePathItem.value(forKey: "urlPath") as? String
            
            print(" This is a file Path: \(filePath)")
            
            let nextViewCon = segue.destination as! TestViewController
            
            
            
            nextViewCon.passedURL = filePath
        } else if segue.identifier == "videoAtributes" {
            //
            
            let destinationVC = segue.destination as! VideoAtrributesViewController
            
            destinationVC.passedVideoURL = fileName
        }
        
        
        
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            guard let videos = passedRecipient?.videos else {return 0}
            return videos.count
        } else if section == 1 {
            guard let audios = passedRecipient?.voice else {return 0}
            return audios.count
        } else if section == 2 {
            guard let writtens = passedRecipient?.written else {return 0}
            return writtens.count
        } else {
            return 0
        }
        
    
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memo", for: indexPath) as! UserCollectionViewCell
        
       // var sectionNumber = indexPath.section
    
        // Configure the cell
      
        if indexPath.section == 0 {
        
            guard let video = passedRecipient?.videos?[indexPath.row] as? Videos else {return cell}
            
            
            var texts = combinedArray[indexPath.row]
        
        if texts.value(forKey: "isVideo") as? Bool == true {

    cell.cellTextLabel.text = texts.value(forKey: "videoTag") as? String
            
            if let picture = texts.value(forKey: "thumbNail") as? Data {
                cell.videoImage.image = UIImage(data: picture)
                
            }
            
            
        } else if texts.value(forKey: "isVoiceMemo") as? Bool == true {
            cell.cellTextLabel.text = texts.value(forKey: "audioTag") as? String
        }
        
        return cell
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tappedItem = combinedArray[indexPath.row]
        guard let tappedItemType = tappedItem.value(forKey: "isVideo") as? Bool else{
            return
        }
        
        guard let tappedItemURL = tappedItem.value(forKey: "urlPath") as? String else {
            return
        }
        
        if tappedItemType{
//            performSegue(withIdentifier: "playVideo", sender: collectionView.cellForItem(at: indexPath))
            
            
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(tappedItemURL)
            
            let videoURL = URL(string: dataPath.absoluteString)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
            
        } else if !tappedItemType {
           let audioFile = self.getDocumentsDirectory().appendingPathComponent(tappedItemURL)
            
            
            do{
                audioPlayer =  try AVAudioPlayer(contentsOf: audioFile)
                
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                
                print("Could not play.")
            }
            
        }
        
        
    }
    
   
    
   

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}



extension MainCollectionViewController: UINavigationControllerDelegate{}
extension MainCollectionViewController: AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension MainCollectionViewController {
    func previewImageForLocalVideo(url:URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let tVal = NSValue(time: CMTimeMake(12, 1)) as! CMTime
        do {
            let imageRef = try imageGenerator.copyCGImage(at: tVal, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
}



