//
//  RecordingChoiceCollectionViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/23/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import CoreData
import MaterialComponents

class RecordingChoiceCollectionViewController: UICollectionViewController {

     var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        collectionView?.backgroundColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

       

        // Do any additional setup after loading the view.
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
        
       guard let cell = sender as? RecordingChoiceCollectionViewCell,
        let indexPath = self.collectionView?.indexPath(for: cell) else {
            return
        }
//        if segue.identifier == "videoAtributes"{
//        let destinationVC = segue.destination as! VideoAtrributesViewController
//
//        destinationVC.passedVideoURL = fileName
//        } else if segue.identifier == "toWrittenMemo" {
//
//        }
        
        let destinationVC = segue.destination as! LovedOneSelectionTableViewController
        
        if segue.identifier == "toLovedOne" && indexPath.row == 0{
         destinationVC.mediaSelected = "audio"
            
        } else if segue.identifier == "toLovedOne" && indexPath.row == 1 {
            
            destinationVC.mediaSelected = "video"
            
        } else if segue.identifier == "toLovedOne" && indexPath.row == 2 {
            destinationVC.mediaSelected = "written"
        } else if segue.identifier == "toLovedOne" && indexPath.row == 3 {
            destinationVC.mediaSelected = "none"
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "choices", for: indexPath) as! RecordingChoiceCollectionViewCell
        // Configure the cell
        if indexPath.row == 0 {
           
            cell.choiceImage.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            cell.choiceImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_18pt")
            cell.memoChoiceLabel.text = "New Audio"
        } else if indexPath.row == 1 {
            cell.choiceImage.backgroundColor = .red
            cell.choiceImage.image = #imageLiteral(resourceName: "outline_videocam_white_18pt")
            cell.memoChoiceLabel.text = "New Video"
        } else if indexPath.row == 2 {
            
            cell.choiceImage.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            cell.choiceImage.image = #imageLiteral(resourceName: "sharp_edit_white_18pt")
            cell.memoChoiceLabel.text = "New Text"
        } else if indexPath.row == 3 {
            cell.choiceImage.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            cell.choiceImage.image = #imageLiteral(resourceName: "outline_favorite_border_white_18pt")
            cell.memoChoiceLabel.text = "Loved Ones"
        }
       
        
        
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = indexPath.row
        print(selectedItem)
//        if selectedItem == 0 {
//            
//           // self.performSegue(withIdentifier: "newAudioMemo", sender: self)
//            self.performSegue(withIdentifier: "toLovedOne", sender: self)
//            
//        } else if selectedItem == 1 {
//            //VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
//            self.performSegue(withIdentifier: "toLovedOne", sender: self)
//        } else if selectedItem == 2 {
//            self.performSegue(withIdentifier: "toLovedOne", sender: self)
//           // self.performSegue(withIdentifier: "toWrittenMemo", sender: self)
//        }
    }

    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        guard
//        let previousTraitCollection = previousTraitCollection,
//        self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass ||
//        self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass
//            else {
//                return
//        }
//        
//       self.collectionView?.collectionViewLayout.invalidateLayout()
//        self.collectionView?.reloadData()
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
//        self.collectionView?.collectionViewLayout.invalidateLayout()
//        coordinator.animate(alongsideTransition: { (context) in
//            
//        }) { (context) in
//            self.collectionView?.collectionViewLayout.invalidateLayout()
//            self.collectionView?.visibleCells.forEach({ (cell) in
//                guard let cell = cell as? RecordingChoiceCollectionViewCell else {
//                    return
//                }
//                cell.setCircularImageView()
//            })
//        }
//    }
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
    
    
    func save(url:String, _ tempFilePath: URL){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Videos", in: managedContext)!
        
        let videos = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let savedImage = previewImageForLocalVideo(url: tempFilePath) else {
            return
        }
        let savedImageData = UIImagePNGRepresentation(savedImage) as NSData?
        videos.setValue(savedImageData, forKey: "thumbNail")
        videos.setValue(url, forKey: "urlPath")
        videos.setValue(true, forKey: "isVideo")
        videos.setValue(false, forKey: "isVoiceMemo")
        
        let addAtributesAlert = UIAlertController(title: "Add Now?", message: "Would you like to add detials to the video?", preferredStyle: .alert)
        
        addAtributesAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "videoAtributes", sender: self)
        }))
        
        addAtributesAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        do {
            try managedContext.save()
            //videosArray.append(videos)
           // combinedArray.append(videos)
//            let index = IndexPath(row: combinedArray.count - 1, section: 0)
//            collectionView?.insertItems(at: [index])
            DispatchQueue.main.async {
                
                
                
                
                self.present(addAtributesAlert, animated: true, completion: nil)
            }
            
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

}

extension RecordingChoiceCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130,
               height: 110)
    }
    
    
}




extension RecordingChoiceCollectionViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        let nameFileAlert = UIAlertController(title: "File Name", message: "Create a name for your video.", preferredStyle: .alert)
        
        nameFileAlert.addTextField { (textField) -> Void in
            textField.placeholder = "enter a file name"
            textField.textAlignment = .center
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (UIAlertAction) in
            let fileToBeNamed = nameFileAlert.textFields![0] as UITextField
            
            self.fileName = fileToBeNamed.text! + ".mp4"
            
            
            guard
                let mediaType = info[UIImagePickerControllerMediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerControllerMediaURL] as? URL
                else {
                    return
            }
            
            let videoData = try? Data(contentsOf: url )
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath =
                documentsDirectory.appendingPathComponent(self.fileName)
            do {
                let videoSaved = try videoData?.write(to: dataPath, options: [])
                //                DispatchQueue.main.async {
                //                    self.performSegue(withIdentifier: "playVIdeo", sender: self)
                //                }
                
                self.save(url: self.fileName, dataPath)
                
            }
            catch {
                print("The video did not save")
                return
            }
            print("saved!")
            
            
            
        }
        
        nameFileAlert.addAction(saveAction)
        
        
        self.present(nameFileAlert, animated: true, completion: nil)
    }
    
}

extension RecordingChoiceCollectionViewController: UINavigationControllerDelegate{}
extension RecordingChoiceCollectionViewController: AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension RecordingChoiceCollectionViewController {
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


















