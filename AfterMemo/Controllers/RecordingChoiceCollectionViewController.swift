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
    var videoToPass: Videos?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
       // collectionView?.backgroundColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0)
        
        let myImageView: UIImageView = {
            let imageView = UIImageView(image:#imageLiteral(resourceName: "iStock-174765643 (2)"))
            imageView.clipsToBounds = true
//            imageView.frame = CGRect(x: 0, y: 200, width: UIApplication.shared.statusBarFrame.width, height: 100)
//            imageView.contentMode = .center
            
            return imageView
        }()
        
     collectionView?.backgroundView = myImageView
//        collectionView?.backgroundColor = .clear
       
        
        let layout = self.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumLineSpacing = 8

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
            
            guard let selectionController = storyboard?.instantiateViewController(withIdentifier: "selection") as? SelectionCollectionViewController else {
                
                print(" I didn't work :(")
                return
            }
            
           
            
            
            destinationVC.mediaSelected = "video"
            
        } else if segue.identifier == "toLovedOne" && indexPath.row == 2 {
            destinationVC.mediaSelected = "written"
        } else if segue.identifier == "toLovedOne" && indexPath.row == 3 {
            destinationVC.mediaSelected = "none"
        } else if segue.identifier == "toLovedOne" && indexPath.row == 4 {
            destinationVC.mediaSelected = "downloads"
            
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
           
           
           
           
            cell.choiceImage.image = #imageLiteral(resourceName: "audioPic")
            cell.memoChoiceLabel.text = "New Audio"
        } else if indexPath.row == 1 {
           
            //cell.choiceImage.backgroundColor = .red
            cell.choiceImage.image = #imageLiteral(resourceName: "VideoPic")
            cell.memoChoiceLabel.text = "New Video"
        } else if indexPath.row == 2 {
            
          
            cell.choiceImage.image = #imageLiteral(resourceName: "WrittenPic")
            cell.memoChoiceLabel.text = "New Text"
        } else if indexPath.row == 3 {
            
          
            cell.choiceImage.image = #imageLiteral(resourceName: "lovedOnePic")
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
    
    
    
    

}

extension RecordingChoiceCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130,
               height: 130)
    }
    
    
}


extension RecordingChoiceCollectionViewController: UINavigationControllerDelegate{}



















