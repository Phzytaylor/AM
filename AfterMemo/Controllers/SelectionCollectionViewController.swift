//
//  SelectionCollectionViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/23/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

private let reuseIdentifier = "content"

class SelectionCollectionViewController: UICollectionViewController {

    let randomArray = ["one", "two", "tree"]
    
    var appBar = MDCAppBar()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "AfterMemo"
        

        self.addChildViewController(appBar.headerViewController)
        self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView
        appBar.addSubviewsToParent()
        
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
         
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(MDCCardCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            return 1
        } else if section == 1{
            return randomArray.count
            
        }
        else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    var section = indexPath.section
        
        
        if section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath)
            
                let recordingChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "recordingChoice") as! RecordingChoiceCollectionViewController
                self.addChildViewController(recordingChoiceViewController)
                recordingChoiceViewController.view.frame = cell.bounds
                cell.addSubview(recordingChoiceViewController.view)
                recordingChoiceViewController.didMove(toParentViewController: self)
            
            
            
                return cell
            
            
        } else if section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! SelectionCollectionViewCell
            cell.isSelectable = true
            //cell.selectedImageTintColor = .blue
            //cell.backgroundColor = .blue
            cell.cornerRadius = 8
            cell.setShadowElevation(ShadowElevation(rawValue: 6), for: .selected)
            cell.setShadowColor(UIColor.black, for: .highlighted)
            cell.setImage(#imageLiteral(resourceName: "sharp_edit_white_48pt"), for: .normal)
           return cell
          
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! SelectionCollectionViewCell
            
            return cell
            
        }
        
     
        
        // Configure the cell
    
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
   
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionFooter:
            //3
            let section = indexPath.section
            if section == 0 {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "AfterMemoFooter",
                                                                             for: indexPath)
            
            return footerView
            } else {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: "AfterMemoFooter",
                                                                                 for: indexPath)
                footerView.isHidden = true
                
                return footerView
            }
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




extension SelectionCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let section = indexPath.section
        
        var deviceOrientation = UIDevice.current.orientation
        
      if section == 0 && deviceOrientation.isLandscape == true {
        //let width = Int(collectionView.frame.width)
        
            return CGSize(width: collectionView.frame.width * 0.5, height: 110)
            
      } else if section == 0 && deviceOrientation.isLandscape == false {
        let width = Int(collectionView.frame.width)
        
        return CGSize(width: width, height: 110)
      }
      else if section == 1 {let width = Int(collectionView.frame.width)
            
            return CGSize(width: 200, height: 220)
            
        }
        else {
            return UICollectionViewFlowLayoutAutomaticSize
        }
        
    }
}
extension SelectionCollectionViewController {
    
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


















