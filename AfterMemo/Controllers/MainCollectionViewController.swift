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
import MaterialComponents


private let reuseIdentifier = "memo"

class MainCollectionViewController: UICollectionViewController {
    
   
   
    
    

    // MARK: - Properties
    var fileName = ""
    var audioPlayer: AVAudioPlayer?
    var passedRecipient: Recipient?
    var videosArray: [NSManagedObject] = []
    var voiceMemosArray: [NSManagedObject] = []
    
    var combinedArray: [NSManagedObject] = []
    
    var appBar = MDCAppBar()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 20) / 2
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width:width, height:width)
        
        
        self.addChildViewController(appBar.headerViewController)
        self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView
        appBar.addSubviewsToParent()
        
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        guard let videos = passedRecipient?.videos else {
            print(" NOT WORKING")
            return }
        
        print(videos.count)
        
        
        
  
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
            
            guard let filePathItem = passedRecipient?.videos?[indexPath.row] as? Videos else{
                return
            }
            
            let filePath = filePathItem.urlPath
            print(" This is a file Path: \(filePath)")
            
            let nextViewCon = segue.destination as! TestViewController
            
            
            
            nextViewCon.passedURL = filePath
        } else if segue.identifier == "videoAtributes" {
            //
            
            let destinationVC = segue.destination as! VideoAtrributesViewController
            
            destinationVC.passedVideoURL = fileName
        } else if segue.identifier == "textMemoPreview" {
            
            
            guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                return
            }
            
            let destinationVC = segue.destination as! TextMemoPreviewViewController
            
            guard let textToPass = passedRecipient?.written?[indexPath.row] as? Written else {return}
            
            destinationVC.textForMemo = textToPass.memoText
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
            guard let videos = passedRecipient?.videos else {
                print(" NOT WORKING")
                return 0}
            
            print(videos.count)
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
        
            guard let video = passedRecipient?.videos?[indexPath.row] as? Videos else {
                
                print("I am not working")
                return cell}
            
            
        
        if video.value(forKey: "isVideo") as? Bool == true {
            
            var textForCell = video.value(forKey: "videoTag") as? String
            
            if textForCell == nil {
                
                if let picture = video.value(forKey: "thumbNail") as? Data {
                    cell.videoImage.image = UIImage(data: picture)
                    
                }
                
                return cell
            } else {
                 cell.cellTextLabel.text = video.value(forKey: "videoTag") as? String
                if let picture = video.value(forKey: "thumbNail") as? Data {
                    cell.videoImage.image = UIImage(data: picture)
                    
                }
                
                return cell
                
            }

   
            
            
            
        }
            
            
        } else if indexPath.section == 1 {
            guard let voices = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else {return cell}
            
            
            
            if voices.value(forKey: "isVoiceMemo") as? Bool == true {
                var textForCell = voices.value(forKey: "audioTag") as? String
                
                if textForCell == nil {
                  
                    cell.videoImage.contentMode = .scaleAspectFit
                    cell.videoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                    
                } else {
                    cell.cellTextLabel.text = voices.value(forKey: "audioTag") as? String
                    cell.videoImage.contentMode = .scaleAspectFit
                    cell.videoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                }
                
                
            }
            
            
        } else if indexPath.section == 2 {
            
            guard let writtens = passedRecipient?.written?[indexPath.row] as? Written else {return cell}
            if writtens.value(forKey: "isWrittenMemo") as? Bool == true {
            
                cell.cellTextLabel.text = writtens.value(forKey: "writtenTag") as? String
                cell.videoImage.contentMode = .scaleAspectFit
                cell.videoImage.image = #imageLiteral(resourceName: "outline_chat_white_48pt")
                
                return cell
                
                
            }
            
        }
        return cell
        }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let section = indexPath.section
        
        if section == 0 {
            
            guard let video = passedRecipient?.videos?[indexPath.row] as? Videos else {
                
               
                return}
            
            guard let videoURL = video.urlPath else {return}
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(videoURL)
            
            guard let videoURLForPlayBack = URL(string: dataPath.absoluteString) else {return}
            let player = AVPlayer(url: videoURLForPlayBack)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } else if section == 1 {
            
            guard let audio = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else {return}
            
            guard let audioURL = audio.urlPath else {return}
            
            let audioFile = self.getDocumentsDirectory().appendingPathComponent(audioURL)
            
            
            do{
                audioPlayer =  try AVAudioPlayer(contentsOf: audioFile)
                
                audioPlayer?.delegate = self
                audioPlayer?.stop()
                audioPlayer?.play()
            } catch {
                
                print("Could not play.")
            }
            
        } else if section == 2 {
            //TODO: -Implement a screen to view the written
            
            performSegue(withIdentifier: "textMemoPreview", sender: collectionView.cellForItem(at: indexPath))
        }
  
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "mediaHeader",
                                                                             for: indexPath) as! MediaHeader
            let section = indexPath.section
            if section == 0 {
                
                
                headerView.mediaLabel.text = "Video Memos"
                
                
            } else if section == 1 {

                headerView.mediaLabel.text = "Voice Memos"
                
                
            } else if section == 2 {
                
               headerView.mediaLabel.text = "Text Memos"
                
                
                
            }
            
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
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
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }
}



