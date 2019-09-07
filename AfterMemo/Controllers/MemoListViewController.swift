//
//  MemoListViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 8/29/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents
import CoreData
import AVKit
import MobileCoreServices


class MemoListViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var filterBar: UISegmentedControl!
    @IBOutlet weak var memoTableView: UITableView!
    
    var appBar = MDCAppBar()
    let memoHeaderView = MemoHeaderView()
    var timer: Timer?
    var fileName = ""
    var audioPlayer: AVAudioPlayer?
    var passedRecipient: Recipient?
    var videosSet: NSOrderedSet?
    var voiceMemosSet: NSOrderedSet?
    var textMemoSet: NSOrderedSet?
    var combinedArray: [NSManagedObject] = []
    var orderedCombinedArray: [Any] = []
    var audioFirstCombined: [Any] = []
    var videoFirstCombined: [Any] = []
    var textFirstCombined: [Any] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedContext: NSManagedObjectContext!
    
    let creationItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "outline_add_circle_white_24pt"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(goToCreate))
    
    
    
    //MARK: - Methods
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
        
    }
    
    func animateTable(){
        
        memoTableView.reloadData()
        let cells = memoTableView.visibleCells
        let tableHeight: CGFloat = memoTableView.bounds.size.height
        memoTableView.alpha = 0
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for m in cells {
            let cell: UITableViewCell = m as UITableViewCell
            UIView.animate(withDuration: 3.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity:0, options: [], animations: {
                self.memoTableView.alpha = 1.0
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            index += 1
        }
    }
    
   @objc func goToCreate(){
        self.performSegue(withIdentifier: "toOptions", sender: self)
    }
    
    func flattenedArray(array:[Any]) -> [Any] {
        var myArray = [Any]()
        for element in array {
            
                myArray.append(element)
            
            if let element = element as? [Any] {
                let result = flattenedArray(array: element)
                for i in result {
                    myArray.append(i)
                }
                
            }
        }
        return myArray
    }
    
    @IBAction func filterList(_ sender: Any) {
        
        guard let passedPerson = passedRecipient else {
            print("could not set person")
            return
        }
        
        switch filterBar.selectedSegmentIndex {
        case 0:
            let mutableVidSet = passedPerson.videos?.mutableCopy() as? NSMutableOrderedSet
            let mutableAudioSet = passedPerson.voice?.mutableCopy() as? NSMutableOrderedSet
            let mutableWrittenSet = passedPerson.written?.mutableCopy() as? NSMutableOrderedSet
            let sortDescriptor = NSSortDescriptor(key: "dateToBeReleased", ascending: true)
            //            mutableVidSet?.sort(using: [sortDescriptor])
            //            mutableAudioSet?.sort(using: [sortDescriptor])
            //            mutableWrittenSet?.sort(using: [sortDescriptor])
            
            mutableAudioSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            
            mutableWrittenSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            
            var allSet = mutableVidSet?.sortedArray(using: [sortDescriptor])
            
            orderedCombinedArray = allSet ?? [0]
            animateTable()
            
            
        case 1:
            let mutableVidSet = videosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableAudioSet = voiceMemosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableWrittenSet = textMemoSet?.mutableCopy() as? NSMutableOrderedSet
            
            
            let sortDescriptor = NSSortDescriptor(key: "mileStone", ascending: true)
            
            
            mutableAudioSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            
            mutableWrittenSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            
            var allSet = mutableVidSet?.sortedArray(using: [sortDescriptor])
            
            orderedCombinedArray = allSet ?? [0]
            
            animateTable()
        case 2:
            let mutableVidSet = videosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableAudioSet = voiceMemosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableWrittenSet = textMemoSet?.mutableCopy() as? NSMutableOrderedSet
            
            
          /*  mutableAudioSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            
            mutableWrittenSet?.forEach({ (element) in
                mutableVidSet?.add(element)
            })
            */
            orderedCombinedArray = mutableVidSet?.array ?? [0]
            animateTable()
        case 3:
            let mutableVidSet = videosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableAudioSet = voiceMemosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableWrittenSet = textMemoSet?.mutableCopy() as? NSMutableOrderedSet
            
            
         /*   mutableVidSet?.forEach({ (element) in
                mutableAudioSet?.add(element)
            })
            
            mutableWrittenSet?.forEach({ (element) in
                mutableAudioSet?.add(element)
            })
            */
            orderedCombinedArray = mutableAudioSet?.array ?? [0]
            animateTable()
        case 4:
           
            let mutableVidSet = videosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableAudioSet = voiceMemosSet?.mutableCopy() as? NSMutableOrderedSet
            let mutableWrittenSet = textMemoSet?.mutableCopy() as? NSMutableOrderedSet
            
            
         /*   mutableVidSet?.forEach({ (element) in
                mutableWrittenSet?.add(element)
            })
            
            mutableAudioSet?.forEach({ (element) in
                mutableWrittenSet?.add(element)
            })
            */
            orderedCombinedArray = mutableWrittenSet?.array ?? [0]
            animateTable()
        default:
            print("Hello")
        }
        
    }
    
    
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
 
        appBar.addSubviewsToParent()
  
    }
    //TODO: Update Timer Implementiaton once tableView is complete
    
    func getProgress() -> Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        
        if let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }

    
    
    func startTimer(sender:Any?){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateViewsWithTimer(theTimer:)), userInfo: sender, repeats: true)
    }


    @objc func updateViewsWithTimer(theTimer: Timer) {
        let theSender = timer?.userInfo
        updateViews(sender: theSender)
    }

    func updateViews(sender:Any?){
        let progress = getProgress()
        guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
            print("I failed")
            return
        }

        guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
            return
        }
        print(userCell.audioProgress.progress)
        userCell.audioProgress.progress = progress



        if  audioPlayer?.isPlaying == false {

            //userCell.videoImage.image = #imageLiteral(resourceName: "twotone_account_circle_black_24pt")

            print("Done")

            timer?.invalidate()

            self.memoTableView.deselectRow(at: indexPath, animated: true)
        }

    }
    
    
    @IBAction func AtrributesAction(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? MemoListViewTableViewCell else {
            print("Not the sender")
            return
        }
        
        guard let indexPath = memoTableView.indexPath(for: cell) else {return}
        
        let memo = orderedCombinedArray[indexPath.row]
        
        if memo is Videos {
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to preview the memo's settings or edit them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "Preview Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Edit Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier:"videoAtributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
            
            
        } else if memo is VoiceMemos {
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to preview the memo's settings or edit them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "Preview Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Edit Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "voiceMemoAtts", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Edit Recording", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "editAudio", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
            
            
        } else if memo is Written {
            //need to view the attributes of the textView!
            
            let selectionAlert = UIAlertController(title: "Select One", message: "Would you like to preview the memo's settings or edit them?", preferredStyle: .actionSheet)
            selectionAlert.addAction(UIAlertAction(title: "Preview Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "generalAttributes", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Edit Settings", style: .default, handler: { (Action) in
                self.performSegue(withIdentifier: "editWritten", sender: cell)
            }))
            
            selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(selectionAlert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    //MARK: -Start of Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        configureAppBar()
        memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        memoHeaderView.imageViewCenterCon?.isActive = true
        
        memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: memoHeaderView.centerYAnchor, constant: -30.0)
        
        memoHeaderView.imageViewYCon?.isActive = true
        
        self.appBar.navigationBar.rightBarButtonItems = [self.creationItem]
        
        self.appBar.navigationBar.tintColor = .white
        
        memoHeaderView.imageView.layoutIfNeeded()
        
       
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        
        
        
        if let personPassed = passedRecipient {
            videosSet = personPassed.videos
            voiceMemosSet = personPassed.voice
            textMemoSet = personPassed.written
            var tempArray: [Any] = []
            
            if let vidArray = videosSet?.array, let voiceArray = voiceMemosSet?.array, let textArray = textMemoSet?.array {
                
                vidArray.forEach { (element) in
                    tempArray.append(element)
                }
                voiceArray.forEach { (element) in
                    tempArray.append(element)
                }
                
                textArray.forEach { (element) in
                    tempArray.append(element)
                }
                
                orderedCombinedArray = tempArray
            }
  
       memoTableView.tableFooterView = UIView()
            
            animateTable()
        // Do any additional setup after loading the view.
    }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "videoAtributes" {
 
            if sender is MemoListViewTableViewCell {
                print("The Sender was a cell")
                guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
                    print("I failed")
                    return
                }
                
                guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                    return
                }
                
                let memo = orderedCombinedArray[indexPath.row]
                
                    guard let filePathItem = memo as? Videos else{
                        return
                    }
                    
                    let destinationVC = segue.destination as! VideoAtrributesViewController
                    
                    destinationVC.passedVideo = filePathItem
                    destinationVC.selectedPerson = passedRecipient
                    destinationVC.passedSender = sender
                    
                }
        } else if segue.identifier == "textMemoPreview" {
            
            
            guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                return
            }
            
            let destinationVC = segue.destination as! TextMemoPreviewViewController
            
            let memo = orderedCombinedArray[indexPath.row]
            
            if memo is Written {
                guard let textToPass = memo as? Written else {return}
                
                guard let personToPass = passedRecipient else {return}
                
                destinationVC.textForMemo = textToPass.memoText
                destinationVC.lovedOneSelected = personToPass
                
            }
            
          
        } else if segue.identifier == "voiceMemoAtts" {
            
            
            if sender is MemoListViewTableViewCell {
                guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else
                {
                print("I failed")
                return
                }
                
                guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                    return
                }
                
                let memo = orderedCombinedArray[indexPath.row]
                
                
                if memo is VoiceMemos {
                    guard let filePathItem = memo as? VoiceMemos else{
                        return
                    }
                    
                    let destinationVC = segue.destination as! VoiceMemoAtrributeViewController
                    
                    destinationVC.sentVoiceMemo = filePathItem
                    destinationVC.selectedPerson = passedRecipient
                    destinationVC.passedSender = sender
                }
            }

        } else if segue.identifier == "editWritten" {
            
            guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
                print("I failed")
                return
            }
            guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                return
            }
            
            let memo = orderedCombinedArray[indexPath.row]
            
            if memo is Written {
                guard let filePathItem = memo as? Written else{
                    return
                }
                
                let destinationVC = segue.destination as! WrittenMemoViewController
                
                destinationVC.passedMemo = filePathItem
                destinationVC.selectedPerson = passedRecipient
                destinationVC.passedSender = sender
                
            }
            
        }else if segue.identifier == "generalAttributes" {
            guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                return
            }
            
             let memo = orderedCombinedArray[indexPath.row]
            
            
            switch memo {
            case is Videos:
                guard let videoToPass = memo as? Videos else{
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
            case is VoiceMemos:
                
                guard let audioToPass = memo as? VoiceMemos else{
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
            case is Written:
                
                guard let textToPass = memo as? Written else{
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
            
            let destination = segue.destination as! UINavigationController
            let topView = destination.topViewController as! OptionsViewController
            
            topView.passedPerson = passedRecipient
            
//            let destination = segue.destination as! OptionsViewController
//
//            destination.passedPerson = passedRecipient
        } else if segue.identifier == "editAudio" {
            guard let destination = segue.destination as? AudioEditingViewController else {return}
            
            
            guard let userCell: MemoListViewTableViewCell = sender as? MemoListViewTableViewCell else {
                print("I failed")
                return
            }
            
            guard let indexPath: IndexPath = memoTableView?.indexPath(for: userCell) else {
                return
            }
            
            let memo = orderedCombinedArray[indexPath.row]
            
            guard let choosenItem = memo as? VoiceMemos else {return}
            
            guard let audioURL = choosenItem.urlPath else {return}
            
            guard let audioFileToPass:URL = self.getDocumentsDirectory().appendingPathComponent(audioURL) else {return
                print("There was  no file to be sent")
            }
            print("----------")
            print(audioFileToPass)
            print("//////*****///////")
            
            destination.originalAudioFile = audioFileToPass
            destination.segueSender = self
        }
        
        
    }
 

}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   /* func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Video Memos"
        case 1:  return "Audio Memos"
        case 2: return "Written Memos"
        default:
            return "No Memos"
        }
    } */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       /* switch section {
        case 0:
            return videosSet?.count ?? 0
        case 1:  return voiceMemosSet?.count ?? 0
        case 2: return textMemoSet?.count ?? 0
        default:
            return 0
        } */
        
        return orderedCombinedArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testForNow", for: indexPath) as! MemoListViewTableViewCell
        
        cell.isEditing = isEditing
        
        // var sectionNumber = indexPath.section
        
        let memo = orderedCombinedArray[indexPath.row]
        
        // Configure the cell
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy"
        

        let timeFormat = DateFormatter()

        timeFormat.dateFormat = "h:mm a"

        var dateString = "No Date Set"
        var timeString = "No Time Set"
        
        
        switch memo {
        case is Videos:
            
            guard let memoType = memo as? Videos else {
                return cell
            }
            
            cell.audioProgress.isHidden = true
            
            if let dateToConvert = memoType.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }
            
            if let timetoConvert = memoType.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            
            if memoType.value(forKey: "isVideo") as? Bool == true {
                
                let textForCell = memoType.value(forKey: "mileStone") as? String
                
                if textForCell == nil {
                    
//                    if let picture = memoType.value(forKey: "thumbNail") as? Data {
//                        cell.memoImage.image = UIImage(data: picture)
//                    }
                    cell.memoImage.image = #imageLiteral(resourceName: "video-icon")

                } else {
                    cell.nameLabel.text = memoType.value(forKey: "mileStone") as? String
                    cell.memoImage.image = #imageLiteral(resourceName: "video-icon")
//                    if let picture = memoType.value(forKey: "thumbNail") as? Data {
//                        cell.memoImage.image = UIImage(data: picture)
//
//                    }
   
                }
                
            }
        return cell
       
        case is VoiceMemos:
            
            guard let memoType = memo as? VoiceMemos else {
                return cell
            }
            
            cell.audioProgress.isHidden = false
           if let dateToConvert = memoType.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }
 
            if let timetoConvert = memoType.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            if memoType.value(forKey: "isVoiceMemo") as? Bool == true {
                var textForCell = memoType.value(forKey: "mileStone") as? String
                
                if textForCell == nil {
                    cell.memoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")

                } else {
                    cell.nameLabel.text = memoType.value(forKey: "mileStone") as? String
                    
                    cell.memoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                }
            }
            
            return cell
            
        case is Written:
            guard let memoType = memo as? Written else {
                return cell
            }
            
            if let dateToConvert = memoType.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }

            if let timetoConvert = memoType.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            
            cell.audioProgress.isHidden = true
            
            if memoType.value(forKey: "isWrittenMemo") as? Bool == true {
                
                cell.nameLabel.text = memoType.value(forKey: "mileStone") as? String
                
                cell.memoImage.image = #imageLiteral(resourceName: "outline_chat_white_48pt")
            }
            return cell
        default:
            cell.backgroundColor = .black
            
            return cell
        }
        
        
        /*
        if indexPath.section == 0 {
            
            cell.audioProgress.isHidden = true
            
            
//            dateFormat.string(from: video.dateToBeReleased! as Date)
            
            guard let video = videosSet?[indexPath.row] as? Videos else {
                
                print("I am not working")
                return cell}
           
            //videosArray.append(video)
            
            if let dateToConvert = video.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }
            
            
            
            if let timetoConvert = video.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            
            if video.value(forKey: "isVideo") as? Bool == true {
                
                let textForCell = video.value(forKey: "videoTag") as? String
                
                
                
                if textForCell == nil {
                    
                    if let picture = video.value(forKey: "thumbNail") as? Data {
                        cell.memoImage.image = UIImage(data: picture)
                        
                    }
                    
                    return cell
                } else {
                    cell.nameLabel.text = video.value(forKey: "videoTag") as? String
                    if let picture = video.value(forKey: "thumbNail") as? Data {
                        cell.memoImage.image = UIImage(data: picture)
                        
                        
                        
                    }
                    
                    return cell
                    
                }
                
            }
            
            
        } else if indexPath.section == 1 {
            guard let voices = voiceMemosSet?[indexPath.row] as? VoiceMemos else {return cell}
            
            if let dateToConvert = voices.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }
            
            
            
            if let timetoConvert = voices.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            
            //voiceMemosArray.append(voices)
            
            if voices.value(forKey: "isVoiceMemo") as? Bool == true {
                var textForCell = voices.value(forKey: "audioTag") as? String
                
                if textForCell == nil {
                    
                    
                    cell.memoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                    
                } else {
                    cell.nameLabel.text = voices.value(forKey: "audioTag") as? String
                   
                    cell.memoImage.image = #imageLiteral(resourceName: "sharp_mic_none_white_48pt")
                    return cell
                }
                
                
            }
            
            
        } else if indexPath.section == 2 {
            
            guard let writtens = textMemoSet?[indexPath.row] as? Written else {return cell}
            
            if let dateToConvert = writtens.dateToBeReleased as Date? {
                dateString = dateFormat.string(from: dateToConvert)
                cell.releaseDateLbl.text = dateString
            }
            
            
            
            if let timetoConvert = writtens.releaseTime as Date? {
                timeString = timeFormat.string(from: timetoConvert)
                cell.releaseTimeLbl.text = timeString
            }
            
            cell.audioProgress.isHidden = true
            
            //textMemoArray.append(writtens)
            if writtens.value(forKey: "isWrittenMemo") as? Bool == true {
                
                cell.nameLabel.text = writtens.value(forKey: "writtenTag") as? String
               
                cell.memoImage.image = #imageLiteral(resourceName: "outline_chat_white_48pt")
                //                cell.propertiesButton.isHidden = true
                
                return cell
                
                
            }
            
        }
        return cell
        
        */
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let section = indexPath.section
        
         let memo = orderedCombinedArray[indexPath.row]
        
        switch memo {
        case is Videos:
            guard let choosenItem = memo as? Videos else {return}
            
            guard let videoURL = choosenItem.urlPath else {return}
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
            
        case is VoiceMemos:
            guard let choosenItem = memo as? VoiceMemos else {return}
            
            guard let audioURL = choosenItem.urlPath else {return}
            
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
                                startTimer(sender: memoTableView.cellForRow(at: indexPath))
            
                            } catch {
            
                                print("Could not play.")
                            }
            
                        }
            
        case is Written:
            guard let choosenItem = memo as? Written else {return}
            
            if !isEditing {
                performSegue(withIdentifier: "textMemoPreview", sender: memoTableView.cellForRow(at: indexPath))
                            }
        default:
            print("No items to choose")
        }
        
        
//        if section == 0 {
//
//            guard let video = videosSet?[indexPath.row] as? Videos else {
//
//                return}
//
//            guard let videoURL = video.urlPath else {return}
//            let paths = NSSearchPathForDirectoriesInDomains(
//                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
//            let dataPath = documentsDirectory.appendingPathComponent(videoURL)
//
//            guard let videoURLForPlayBack = URL(string: dataPath.absoluteString) else {return}
//            let player = AVPlayer(url: videoURLForPlayBack)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//
//            if !isEditing {
//                self.present(playerViewController, animated: true) {
//                    playerViewController.player!.play()
//                }
//            }
//        } else if section == 1 {
//            guard let audio = voiceMemosSet?[indexPath.row] as? VoiceMemos else {return}
//
//            guard let audioURL = audio.urlPath else {return}
//
//            let audioFile = self.getDocumentsDirectory().appendingPathComponent(audioURL)
//            if !isEditing {
//
//                do{
//                    audioPlayer =  try AVAudioPlayer(contentsOf: audioFile)
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                    timer?.invalidate()
//                    audioPlayer?.delegate = self
//                    audioPlayer?.stop()
//                    audioPlayer?.prepareToPlay()
//                    audioPlayer?.play()
//                    startTimer(sender: memoTableView.cellForRow(at: indexPath))
//
//                } catch {
//
//                    print("Could not play.")
//                }
//
//            }
//
//        } else if section == 2 {
//            //TODO: -Implement a screen to view the written
//            if !isEditing {
//                performSegue(withIdentifier: "textMemoPreview", sender: memoTableView.cellForRow(at: indexPath))
//            }
//        }
        
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        if editingStyle == .delete {
            
             let memo = orderedCombinedArray[indexPath.row]
            if memo is Videos {
                
                
                guard let itemDelFromCore = memo as? Videos else {
                    print("Could not delete this video")
                    return
                }
                context.delete(itemDelFromCore)
                appDelegate.saveContext()
                orderedCombinedArray.remove(at: indexPath.row)
                
               
                memoTableView.deleteRows(at: [indexPath], with: .fade)
 
                view.layer.add(animation, forKey: "position")
            } else if memo is VoiceMemos {
               
                
                guard let itemDelFromCore = memo as? VoiceMemos else {
                    print("Could not delete this video")
                    return
                }
              
                context.delete(itemDelFromCore)
                appDelegate.saveContext()
                orderedCombinedArray.remove(at: indexPath.row)
                
               
                memoTableView.deleteRows(at: [indexPath], with: .fade)
                
                view.layer.add(animation, forKey: "position")
            } else if memo is Written {
                
                
                
                guard let itemDelFromCore = memo as? Written else {
                    print("Could not delete this video")
                    return
                }
                
                context.delete(itemDelFromCore)
                appDelegate.saveContext()
               orderedCombinedArray.remove(at: indexPath.row)
                
                memoTableView.deleteRows(at: [indexPath], with: .fade)
                
                view.layer.add(animation, forKey: "position")
                
            }
        }
    
    
    }
    
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
}

extension MemoListViewController: AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
