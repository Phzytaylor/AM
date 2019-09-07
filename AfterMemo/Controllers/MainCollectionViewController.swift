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
import Macaw

import MaterialComponents

private let reuseIdentifier = "memo"

class MainCollectionViewController: UICollectionViewController {
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var timer: Timer?
    
    func startTimer(sender:Any?){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateViewsWithTimer(theTimer:)), userInfo: sender, repeats: true)
    }
    
    @objc func updateViewsWithTimer(theTimer: Timer) {
        let theSender = timer?.userInfo
        updateViews(sender: theSender)
    }
    
    func updateViews(sender:Any?){
        let progress = getProgress()
        guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
            print("I failed")
            return
        }
        
        guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
            return
        }
        print(userCell.progressBar.progress)
        userCell.progressBar.progress = progress
        
       
        
        if  audioPlayer?.isPlaying == false {
            
            //userCell.videoImage.image = #imageLiteral(resourceName: "twotone_account_circle_black_24pt")
            
            print("Done")
            
            timer?.invalidate()
            
            self.collectionView?.deselectItem(at: indexPath, animated: true)
        }
        
        
        
    }
    
    var actionButton = MDCButton()
    var actionButtonBottomConstraint: NSLayoutConstraint?
    var actionButtonCenterConstraint: NSLayoutConstraint?
    
    var filterButton = MDCButton()
    var filterButtonBottomConstraint: NSLayoutConstraint?
    var filterButtonCenterConstraint: NSLayoutConstraint?
    let standardFilter = 0
    let byCreationDateFilter = 1
    let byReleaseDateFilter = 2
    
    
    @IBAction func AtrributesAction(_ sender: UIButton) {
        
        guard let cell = sender.superview?.superview as? UserCollectionViewCell else {return}
        
        let indexPath = collectionView?.indexPath(for: cell)
        
        guard let section = indexPath?.section else {return}
        
        if section == 0 {
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to view the attributes or set them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "View attributes", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Set Attributes", style: .default, handler: { (Action) in
                 self.performSegue(withIdentifier:"videoAtributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
            
           
        } else if section == 1 {
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to view the attributes or set them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "View attributes", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Set Attributes", style: .default, handler: { (Action) in
                 self.performSegue(withIdentifier: "voiceMemoAtts", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
            
           
        } else if section == 2 {
            //need to view the attributes of the textView!
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to view the attributes or set them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "View attributes", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Set Attributes", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "editWritten", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
            
            
        }
        
       
        
        
    }
    

    // MARK: - Properties
    var fileName = ""
    var audioPlayer: AVAudioPlayer?
    var passedRecipient: Recipient?
    var videosArray: [Videos] = []
    var voiceMemosArray: [VoiceMemos] = []
    var textMemoArray: [Written] = []
    var combinedArray: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
      private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var managedContext: NSManagedObjectContext!
    
    var appBar = MDCAppBar()
    var bottomBar = MDCBottomAppBarView()
    let memoHeaderView = GeneralHeaderView()
    
    let collectionTag = 0

    let tableTag = 1
    
    func configureAppBar(){
        self.addChild(appBar.headerViewController)
        appBar.navigationBar.backgroundColor = .clear
        appBar.navigationBar.title = nil
        
        let headerView = appBar.headerViewController.headerView
        headerView.backgroundColor = .clear
        headerView.maximumHeight = MemoHeaderView.Constants.maxHeight
        headerView.minimumHeight = MemoHeaderView.Constants.minHeight
        
        memoHeaderView.frame = headerView.bounds
        headerView.insertSubview(memoHeaderView, at: 0)
        
        headerView.trackingScrollView = self.collectionView
        
        appBar.addSubviewsToParent()
        
       
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    
    
    
    let trashItem = UIBarButtonItem(image: #imageLiteral(resourceName: "outline_delete_white_18pt"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(deleteSelected))
    
    let changeViewButton = UIBarButtonItem(title: "C", style: .plain, target: self, action:#selector(changeCollectionView) )
    
    @objc func changeCollectionView(){
        self.collectionView?.collectionViewLayout.invalidateLayout()
        // change layout soon
        if changeViewButton.tag == collectionTag {
            
            let numberOfCellsPerRow: CGFloat = 1
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
//                let cellWidth = (view.frame.width - 10.0*horizontalSpacing)/numberOfCellsPerRow
                let cellWidth = 200.0
                let cellHeight = 200.0
                flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
                
                actionButtonCenterConstraint?.isActive = false
                actionButtonCenterConstraint = self.actionButton.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50)
                actionButtonCenterConstraint?.isActive = true
                
                filterButtonCenterConstraint?.isActive = false
                filterButtonCenterConstraint = self.filterButton.centerXAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
                filterButtonCenterConstraint?.isActive = true
                
                UIView.animate(withDuration: 2.0, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    
                    
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                
                
                
               
                
                changeViewButton.tag = tableTag
            }
            
        } else if changeViewButton.tag == tableTag {
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                
                flowLayout.minimumLineSpacing = 10
                flowLayout.minimumInteritemSpacing = 5
                flowLayout.sectionInset.top = 5
                flowLayout.sectionInset.bottom = 0
                flowLayout.sectionInset.left = 5
                flowLayout.sectionInset.right = 5
                let cellWidth = 180.0
                let cellHeight = 170.0
                flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            
                actionButtonCenterConstraint?.isActive = false
               actionButtonCenterConstraint = actionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -50)
                actionButtonCenterConstraint?.isActive = true
                
                filterButtonCenterConstraint?.isActive = false
              filterButtonCenterConstraint =
                    filterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 50)
                filterButtonCenterConstraint?.isActive = true
                
                UIView.animate(withDuration: 2.0, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    
                    
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                
                
                changeViewButton.tag = collectionTag
            }
        }
        
       
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            
            if changeViewButton.tag == tableTag {
                actionButtonCenterConstraint?.isActive = false
                actionButtonCenterConstraint =
                self.actionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -50)
                actionButtonCenterConstraint?.isActive = true
                
                filterButtonCenterConstraint?.isActive = false
                
                filterButtonCenterConstraint =
                self.filterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 50)
                filterButtonCenterConstraint?.isActive = true
            UIView.animate(withDuration: 2.0, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {

                self.view.layoutIfNeeded()
                            }, completion: nil)
                
            }
            
        } else {
            print("Portrait")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 20) / 2
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width:width, height:180)
        
        configureAppBar()
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.appBar.navigationBar.tintColor = .white
        
        self.changeViewButton.tag = collectionTag
        

        
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
//        guard let videos = passedRecipient?.videos else {
//            print(" NOT WORKING")
//            return }
//
//        print("The old array is: \(videos)")
//
//        print(videos.count)
        self.editButtonItem.width = 100.0
        
//        var newVideosArray = videos.sortedArray(using: [NSSortDescriptor(key: "creationDate", ascending: true)])
//        print("the new array is: \(newVideosArray)")
//
        
         self.appBar.navigationBar.rightBarButtonItems = [self.editButtonItem, self.changeViewButton]
        
       
        
self.appBar.navigationBar.rightBarButtonItem?.title = "Remove"
        
       
        addButton()
        
        
        
        title = "Memos"
        
        

    }
    //MARK: - Set up Button
    fileprivate func addButton(){
        
      

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false

       
       

//       actionButton.translatesAutoresizingMaskIntoConstraints = false
//        actionButton.setTitle("+", for: UIControlState.normal)
//        actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
//        actionButton.setTitleFont(UIFont.systemFont(ofSize: 30.0), for: .normal)
        actionButton.setImage(UIImage(imageLiteralResourceName: "baseline_add_white_24pt"), for: .normal)
        
        actionButton.imageView?.contentMode = .scaleAspectFill
        actionButton.setImageTintColor(.white, for: .normal)
        
        filterButton.setTitle("Filter", for: UIControl.State.normal)
        filterButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        filterButton.titleLabel?.textAlignment = .center
        
//        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        actionButton.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        filterButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        
        self.view.addSubview(actionButton)
//        self.view.addSubview(filterButton)
        
        actionButtonCenterConstraint = actionButton.centerXAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
        actionButtonCenterConstraint?.isActive = true
        
//        filterButtonCenterConstraint =
//        filterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 50)
//        filterButtonCenterConstraint?.isActive = true
        
        actionButtonBottomConstraint =
        actionButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15.0)
        actionButtonBottomConstraint?.isActive = true
        
//        filterButtonBottomConstraint =
//        filterButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15.0)
//        filterButtonBottomConstraint?.isActive = true
        
       actionButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        filterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
       actionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        filterButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        actionButton.layer.cornerRadius = 25
        actionButton.clipsToBounds = true
        
//        filterButton.layer.cornerRadius = 40
//        filterButton.clipsToBounds = true
        
        
        actionButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)

    }
    
    
    @objc func showMenu(){
        
        performSegue(withIdentifier: "toOptions", sender: self)
    
    }

    func getProgress() -> Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        
        if let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }
    
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if(self.isEditing)
        {
             self.appBar.navigationBar.rightBarButtonItems = [self.editButtonItem,trashItem]
            self.editButtonItem.title = "Done"
        }else
        {
            self.appBar.navigationBar.rightBarButtonItems = [self.editButtonItem, self.changeViewButton]
            self.editButtonItem.title = "Remove"
        }
        collectionView?.allowsMultipleSelection = editing
        guard let indexes = collectionView?.indexPathsForVisibleItems else {return}
        for index in indexes {
            let cell = collectionView?.cellForItem(at: index) as! UserCollectionViewCell
            cell.isEditing = editing
        }
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
            
            if sender is UserCollectionViewCell {
               print("The Sender was a cell")
                guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                    print("I failed")
                    return
                }
                
                guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                    return
                }
                
                let section = indexPath.section
                
                
                if section == 0 {
                    guard let filePathItem = passedRecipient?.videos?[indexPath.row] as? Videos else{
                        return
                    }
                    
                    let destinationVC = segue.destination as! VideoAtrributesViewController
                    
                    destinationVC.passedVideo = filePathItem
                    destinationVC.selectedPerson = passedRecipient
                    destinationVC.passedSender = sender
                    
                }
                
                
            } else {
                print("The Sender was a button not releated to the cell")
                
                guard let personBeingPassed = passedRecipient else {
                    
                    print("Could not set to a person")
                    return
                    
                }
                
                let destinationVC = segue.destination as! VideoAtrributesViewController
                
                destinationVC.selectedPerson = personBeingPassed
                
                destinationVC.passedSender = sender
                
            }

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
            
            guard let personToPass = passedRecipient else {return}
            
            destinationVC.textForMemo = textToPass.memoText
            destinationVC.lovedOneSelected = personToPass
        } else if segue.identifier == "voiceMemoAtts" {
            
            
            if sender is UserCollectionViewCell {guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                print("I failed")
                return
                }
                
                guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                    return
                }
                
                let section = indexPath.section
                
                
                if section == 1 {
                    guard let filePathItem = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else{
                        return
                    }
                    
                    let destinationVC = segue.destination as! VoiceMemoAtrributeViewController
                    
                    destinationVC.sentVoiceMemo = filePathItem
                    destinationVC.selectedPerson = passedRecipient
                    
                }
            } else {
                
                guard let personBeingPassed = passedRecipient else {
                    
                    print("Could not set to a person")
                    return
                    
                }
                
                let destinationVC = segue.destination as! VoiceMemoAtrributeViewController
                
                destinationVC.selectedPerson = personBeingPassed
                
            }
            
            
        } else if segue.identifier == "editWritten" {
            
            guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                print("I failed")
                return
            }
            guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                return
            }
            
            let section = indexPath.section
            
            if section == 2 {
                guard let filePathItem = passedRecipient?.written?[indexPath.row] as? Written else{
                    return
                }
                
                let destinationVC = segue.destination as! WrittenMemoViewController
                
                destinationVC.passedMemo = filePathItem
                destinationVC.selectedPerson = passedRecipient
                destinationVC.passedSender = sender
                
            }

        }else if segue.identifier == "generalAttributes" {
            guard let userCell: UserCollectionViewCell = sender as? UserCollectionViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = collectionView?.indexPath(for: userCell) else {
                return
            }
            
            let section = indexPath.section
            switch section {
            case 0:
                guard let videoToPass = passedRecipient?.videos?[indexPath.row] as? Videos else{
                    return
                }
                
                let destinationVC = segue.destination as! GeneralAttributesViewController
                
                
                guard let memoTag = videoToPass.mileStone else{
                    return
                }
                
                guard let releaseDate = videoToPass.dateToBeReleased else {
                    return
                }
                
                guard let releaseTime = videoToPass.releaseTime else {return}
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                let dateString = dateFormat.string(from: releaseDate as Date)
                
                let timeFormat = DateFormatter()
                
                timeFormat.dateFormat = "h:mm a"
                
                let timeString = timeFormat.string(from: releaseTime as Date)
                
                destinationVC.memoTag = memoTag
                destinationVC.releaseDate = dateString
                destinationVC.releaseTime = timeString
            case 1:
                
                guard let audioToPass = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else{
                    return
                }
                
                let destinationVC = segue.destination as! GeneralAttributesViewController
                
                
                guard let memoTag = audioToPass.mileStone else{
                    return
                }
                
                guard let releaseDate = audioToPass.dateToBeReleased else {
                    return
                }
                
                guard let releaseTime = audioToPass.releaseTime else {return}
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                let dateString = dateFormat.string(from: releaseDate as Date)
                
                let timeFormat = DateFormatter()
                
                timeFormat.dateFormat = "h:mm a"
                
                let timeString = timeFormat.string(from: releaseTime as Date)
                
                destinationVC.memoTag = memoTag
                destinationVC.releaseDate = dateString
                destinationVC.releaseTime = timeString
            case 2:
                
                
                guard let textToPass = passedRecipient?.written?[indexPath.row] as? Written else{
                    return
                }
                
                let destinationVC = segue.destination as! GeneralAttributesViewController
                
                
                guard let memoTag = textToPass.mileStone else{
                    return
                }
                
                guard let releaseDate = textToPass.dateToBeReleased else {
                    return
                }
                
                guard let releaseTime = textToPass.releaseTime else {return}
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                let dateString = dateFormat.string(from: releaseDate as Date)
                
                let timeFormat = DateFormatter()
                
                timeFormat.dateFormat = "h:mm a"
                
                let timeString = timeFormat.string(from: releaseTime as Date)
                
                destinationVC.memoTag = memoTag
                destinationVC.releaseDate = dateString
                destinationVC.releaseTime = timeString
            default:
                print()
            }
            
            
        } else if segue.identifier == "toOptions" {
            
            let destination = segue.destination as! OptionsViewController
            
            destination.passedPerson = passedRecipient
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
        
        cell.isEditing = isEditing
        
       // var sectionNumber = indexPath.section
    
        // Configure the cell
      
        if indexPath.section == 0 {
        cell.progressBar.isHidden = true
           
            guard let video = passedRecipient?.videos?[indexPath.row] as? Videos else {
                
                print("I am not working")
                return cell}
            
            videosArray.append(video)
        
        if video.value(forKey: "isVideo") as? Bool == true {
            
            var textForCell = video.value(forKey: "mileStone") as? String
            
            if textForCell == nil {
                
                if let picture = video.value(forKey: "thumbNail") as? Data {
                    cell.videoImage.image = UIImage(data: picture)
                    
                }
                
                return cell
            } else {
                 cell.cellTextLabel.text = video.value(forKey: "mileStone") as? String
                if let picture = video.value(forKey: "thumbNail") as? Data {
                    cell.videoImage.image = UIImage(data: picture)
                    
                }
                
                return cell
                
            }
  
        }
            
            
        } else if indexPath.section == 1 {
            guard let voices = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else {return cell}

            voiceMemosArray.append(voices)
            
            if voices.value(forKey: "isVoiceMemo") as? Bool == true {
                var textForCell = voices.value(forKey: "mileStone") as? String

                if textForCell == nil {
                  
                    cell.videoImage.contentMode = .scaleAspectFit
                    cell.videoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                    
                } else {
                    cell.cellTextLabel.text = voices.value(forKey: "mileStone") as? String
                    cell.videoImage.contentMode = .scaleAspectFit
                    cell.videoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                }
                
                
            }
            
            
        } else if indexPath.section == 2 {
            
            guard let writtens = passedRecipient?.written?[indexPath.row] as? Written else {return cell}
            
            cell.progressBar.isHidden = true
            
            textMemoArray.append(writtens)
            if writtens.value(forKey: "isWrittenMemo") as? Bool == true {
            
                cell.cellTextLabel.text = writtens.value(forKey: "mileStone") as? String
                cell.videoImage.contentMode = .scaleAspectFit
                cell.videoImage.image = #imageLiteral(resourceName: "outline_chat_white_48pt")
//                cell.propertiesButton.isHidden = true
                
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
            
            if !isEditing {
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
                
                
                }
            }
        } else if section == 1 {
            
            guard let audio = passedRecipient?.voice?[indexPath.row] as? VoiceMemos else {return}
            
            guard let audioURL = audio.urlPath else {return}
            
            let audioFile = self.getDocumentsDirectory().appendingPathComponent(audioURL)
            if !isEditing {
            
            do{
                audioPlayer =  try AVAudioPlayer(contentsOf: audioFile)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
                timer?.invalidate()
                audioPlayer?.delegate = self
                audioPlayer?.stop()
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                startTimer(sender: collectionView.cellForItem(at: indexPath))

            } catch {
                
                print("Could not play.")
                }
                
            }
            
        } else if section == 2 {
            //TODO: -Implement a screen to view the written
            if !isEditing {
                performSegue(withIdentifier: "textMemoPreview", sender: collectionView.cellForItem(at: indexPath))
                
            }
        }
  
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionView.elementKindSectionHeader:
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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "mediaHeader",
                                                                             for: indexPath) as! MediaHeader
            //assert(false, "Unexpected element kind")
            return headerView
        }
    }
    
    
    @objc func deleteSelected(){
        if let selected = collectionView?.indexPathsForSelectedItems {
           var selectedContent = selected
            
           selectedContent.sort()
            selectedContent.reverse()
            
            for content in selectedContent {
                if content.section == 0 {
                   
                    //let videoToDelete = videosArray[content.item]
                    
                    guard let videoToDeleteFromPerson = passedRecipient?.videos?[content.item] as? Videos else {
                        
                        print("I am not working")
                        return}
                    
                   // let videoToDelete = videosArray[content.item]
                    
                    
                    context.delete(videoToDeleteFromPerson)
                    //context.delete(videoToDelete)
                    
                    
                    appDelegate.saveContext()
                    
                    // videosArray.remove(at: content.item)
                } else if content.section == 1 {
                    guard let voiceMemoToDelete = passedRecipient?.voice?[content.item] as? VoiceMemos else {return}
                    
                    context.delete(voiceMemoToDelete)
                    appDelegate.saveContext()
                } else if content.section == 2 {
                    
                    
                    guard let textMemoToDelete = passedRecipient?.written?[content.item] as? Written else {return}
                    context.delete(textMemoToDelete)
                    appDelegate.saveContext()
                }
            }
            
            collectionView?.deleteItems(at: selected)
            
            videosArray.removeAll()
            voiceMemosArray.removeAll()
            textMemoArray.removeAll()
            collectionView?.reloadData()
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
        let tVal = NSValue(time: CMTimeMake(value: 12, timescale: 1)) as! CMTime
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
        
        if scrollView.isTracking{
       
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.actionButton.alpha = 0.0
                self.filterButton.alpha = 0.0
            }, completion: nil)
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
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.actionButton.alpha = 1.0
            self.filterButton.alpha = 1.0
        }, completion: nil)
        
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






// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
