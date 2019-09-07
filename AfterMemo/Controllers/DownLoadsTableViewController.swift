//
//  DownLoadsTableViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/11/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import AVKit
import AVFoundation
import MaterialComponents
import DZNEmptyDataSet
class DownLoadsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var appBar = MDCAppBar()
    var videosToDownload: [VideosFromDatabase] = []
    var voicesToDownload: [VoicesFromDatabase] = []
    var textMemosToDownload: [WrittenFromDatabase] = []
    var personPassed: Recipient?
    var selectedMemoTypePassed = ""
    var ref: DatabaseReference?
    var compelete:CGFloat = 0.0
    let memoHeaderView = GeneralHeaderView()
    
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
        
        headerView.trackingScrollView = self.tableView
        
        appBar.addSubviewsToParent()
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    
//    let progressIndicatorView = CircularLoaderView(frame: .zero)

    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
     let videoRef = Database.database().reference(withPath: "videos")
    
    
    func checkForEntry(memoType: String,uuID: String) -> Bool {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: memoType)
        let predicate = NSPredicate(format: "uuID == %@", uuID)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try context.count(for: request)
            if(count == 0){
                // no matching object
                return false
            }
            else{
                // at least one matching object exists
                return true
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
    }
    
    
    func downLoadMemos(indexPath: IndexPath){
        
        
        guard let cell = tableView.cellForRow(at: indexPath) as? DownloadTableViewCell else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let storage = Storage.storage()
        
        switch selectedMemoTypePassed {
        case "video":
            
           
            
            let videoMemoInfo = videosToDownload[indexPath.row]
            
            let lovedOne = videoMemoInfo.lovedOne
            let videoStorageURL = videoMemoInfo.videoStorageURL
            let videoTag = videoMemoInfo.videoTag
            let releaseDate = videoMemoInfo.releaseDate
            let releaseTime = videoMemoInfo.releaseTime
            let uuID = videoMemoInfo.uuID
            let videoOnDeviceURL = videoMemoInfo.videoOnDeviceURL
            let createdDate = videoMemoInfo.createdDate
            let key = videoMemoInfo.key
            let relation = videoMemoInfo.relation
            
            
            guard let uuid = uuID else {
                return
            }
            
            guard let url = videoStorageURL else {
                return
            }
            
            guard let onDevice = videoOnDeviceURL else {return}
            
            guard let relDate = releaseDate else {return}
            
            guard let cretDate = createdDate else {return}
            
            
            if !checkForEntry(memoType: "Videos", uuID: uuid){
                // Create a reference to the file we want to download
                
                let storageRef = storage.reference(forURL: url)
                
                // Local directory to be saved to
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                
                let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                let dataPath =
                    documentsDirectory.appendingPathComponent(onDevice)
                
                
                // Start the download
                let downloadTask = storageRef.write(toFile: dataPath)
                
                //Observe changes in status
                downloadTask.observe(.resume) { (snapshot) in
                    //Download resumed, also fired when download starts
                    
                    
                }
                
                downloadTask.observe(.pause) { (snapshot) in
                    //Download paused
                }
                
                downloadTask.observe(.progress) { (snapshot) in
                    //Progress of download
                    let percentComplete =  CGFloat(snapshot.progress!.completedUnitCount) / CGFloat(snapshot.progress!.totalUnitCount)
                    
                    print(percentComplete)
                    
                    cell.progressView.progress = percentComplete
                    
                    
                }
                
                downloadTask.observe(.success) { (snapshot) in
                    // Download completed succesfully
                    print("DONE!")
                    let video = Videos(context: managedContext)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat =  "M-d-yyyy" //Your date format
                    guard let date = dateFormatter.date(from: relDate) as NSDate? else {return}
                    
                    guard let createdDateString = dateFormatter.date(from: cretDate) as NSDate? else {return}
                    
                    guard let relTime = releaseTime else {return}
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    guard let time = timeFormatter.date(from: relTime) as NSDate? else {return}
                    
                    guard let savedImage = self.previewImageForLocalVideo(url: dataPath) else {
                        return
                    }
                    
                    let savedImageData = savedImage.pngData() as NSData?
                    
                    
                    video.dateToBeReleased = date
                    video.isVideo = true
                    video.isVoiceMemo = false
                    video.isWrittenMemo = false
                    video.releaseTime = time
                    video.thumbNail = savedImageData
                    video.urlPath = videoOnDeviceURL
                    video.mileStone = videoTag
                    video.uuID = uuID
                    video.creationDate = createdDateString
                    
                    
                    
                    if relation == "undefined" {
                        
                        guard let userID = Auth.auth().currentUser?.uid else {return}
                        guard let dataKey = key else {return}
                        
                        let relationRef = Database.database().reference(withPath: "videos").child(userID).child(dataKey)
                        
                        relationRef.updateChildValues(["relation":self.personPassed?.relation as Any])
                        
                        
                    }
                    
                    
                    if let videos = self.personPassed?.videos?.mutableCopy() as? NSMutableOrderedSet {
                        videos.add(video)
                        self.personPassed?.videos = videos
                    }
                    
                    
                    
                    
                    do {
                        try managedContext.save()
                        print(" I saved")
                        
                        
                        
                        //self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                        
                    }
                    catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        
                        managedContext.delete(video)
                        let errorAlert = UIAlertController(title: "This Video Already Exists!", message: "You already have this video!", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(errorAlert, animated: true, completion: nil)
                        
                        print("THIS EXISTS: \(video.uuID)")
                        
                    }
                    
                    
                }
                
                // Errors only occur in the "Failure" case
                downloadTask.observe(.failure) { snapshot in
                    guard let errorCode = (snapshot.error as NSError?)?.code else {
                        return
                    }
                    guard let error = StorageErrorCode(rawValue: errorCode) else {
                        return
                    }
                    switch (error) {
                    case .objectNotFound:
                        // File doesn't exist
                        break
                    case .unauthorized:
                        // User doesn't have permission to access file
                        break
                    case .cancelled:
                        // User cancelled the download
                        break
                        
                        /* ... */
                        
                    case .unknown:
                        // Unknown error occurred, inspect the server response
                        break
                    default:
                        // Another error occurred. This is a good place to retry the download.
                        break
                    }
                }

            } else {
                
                let errorAlert = UIAlertController(title: "This Video Already Exists!", message: "You already have this video!", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(errorAlert, animated: true, completion: nil)
            }
            
           
        case "audio":
            let voiceMemoInfo = voicesToDownload[indexPath.row]
            
            let lovedOne = voiceMemoInfo.lovedOne
            let audioStorageURL = voiceMemoInfo.audioStorageURL
            let audioTag = voiceMemoInfo.audioTag
            let releaseDate = voiceMemoInfo.releaseDate
            let releaseTime = voiceMemoInfo.releaseTime
            let uuID = voiceMemoInfo.uuID
            let audioOnDeviceURL = voiceMemoInfo.audioOnDeviceURL
            let createdDate = voiceMemoInfo.createdDate
            let relation = voiceMemoInfo.relation
            let key = voiceMemoInfo.key
            
            guard let uuid = uuID else {return}
            
            if !checkForEntry(memoType: "VoiceMemos", uuID: uuid){
                
                
                
                
                // Create a reference to the file we want to download
                guard let audioStor = audioStorageURL else {return}
                let storageRef = storage.reference(forURL: audioStor)
                
                // Local directory to be saved to
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                
                let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                
                guard let audioOnDevURL = audioOnDeviceURL else {return}
                let dataPath =
                    documentsDirectory.appendingPathComponent(audioOnDevURL)
                
                
                // Start the download
                let downloadTask = storageRef.write(toFile: dataPath)
                
                //Observe changes in status
                downloadTask.observe(.resume) { (snapshot) in
                    //Download resumed, also fired when download starts
                }
                
                downloadTask.observe(.pause) { (snapshot) in
                    //Download paused
                }
                
                downloadTask.observe(.progress) { (snapshot) in
                    //Progress of download
                    let percentComplete = CGFloat(snapshot.progress!.completedUnitCount) / CGFloat(snapshot.progress!.totalUnitCount)
                    
                    print(percentComplete)
                    
                    
                    cell.progressView.progress = percentComplete
                    
                    
                }
                
                downloadTask.observe(.success) { (snapshot) in
                    // Download completed succesfully
                    
                    let audio = VoiceMemos(context: managedContext)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, MM-dd-yyyy" //Your date format
                    
                    guard let relDate = releaseDate else {return}
                    guard let date = dateFormatter.date(from: relDate) as NSDate? else {return}
                    
                    guard let cretDate = createdDate else {return}
                    guard let createdDateString = dateFormatter.date(from: cretDate) as NSDate? else {return}
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    
                    guard let relTime = releaseTime else {return}
                    
                    guard let time = timeFormatter.date(from: relTime) as NSDate? else {return}
                    
                    guard let savedImage = self.previewImageForLocalVideo(url: dataPath) else {
                        return
                    }
                    
                    
                    
                    
                    audio.dateToBeReleased = date
                    audio.isVideo = false
                    audio.isVoiceMemo = true
                    audio.isWrittenMemo = false
                    audio.releaseTime = time
                    audio.urlPath = audioOnDeviceURL
                    audio.mileStone = audioTag
                    audio.uuID = uuID
                    audio.creationDate = createdDateString
                    
                    
                    if relation == "undefined" {
                        
                        guard let userID = Auth.auth().currentUser?.uid else {return}
                        
                        guard let theKey = key else {return}
                        
                        let relationRef = Database.database().reference(withPath: "audioMemos").child(userID).child(theKey)
                        
                        relationRef.updateChildValues(["relation":self.personPassed?.relation as Any])
                        
                        
                    }
                    
                    if let audios = self.personPassed?.voice?.mutableCopy() as? NSMutableOrderedSet {
                        audios.add(audio)
                        self.personPassed?.voice = audios
                    }
                    
                    
                    
                    
                    do {
                        try managedContext.save()
                        print(" I saved")
                        
                        
                        
                        //self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                        
                    }
                    catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        
                        managedContext.delete(audio)
                        let errorAlert = UIAlertController(title: "This Recording Already Exists!", message: "You already have this recording!", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(errorAlert, animated: true, completion: nil)
                        
                        print("THIS EXISTS: \(audio.uuID)")
                        
                    }
                    
                    
                }
                
                // Errors only occur in the "Failure" case
                downloadTask.observe(.failure) { snapshot in
                    guard let errorCode = (snapshot.error as NSError?)?.code else {
                        return
                    }
                    guard let error = StorageErrorCode(rawValue: errorCode) else {
                        return
                    }
                    switch (error) {
                    case .objectNotFound:
                        // File doesn't exist
                        break
                    case .unauthorized:
                        // User doesn't have permission to access file
                        break
                    case .cancelled:
                        // User cancelled the download
                        break
                        
                        /* ... */
                        
                    case .unknown:
                        // Unknown error occurred, inspect the server response
                        break
                    default:
                        // Another error occurred. This is a good place to retry the download.
                        break
                    }
                }
            }
            
           
            
            
            
            
            
            
        case "text":
            
            let textMemoInfo = textMemosToDownload[indexPath.row]
            
            
            
            let lovedOne = textMemoInfo.lovedOne
            let writtenTag = textMemoInfo.memoTag
            let releaseDate = textMemoInfo.releaseDate
            let releaseTime = textMemoInfo.releaseTime
            let uuID = textMemoInfo.uuID
            let memoText = textMemoInfo.memoText
            let createdDate = textMemoInfo.createdDate
            let relation = textMemoInfo.relation
            let key = textMemoInfo.key
            
            guard let uuid = uuID else {return}
            
            if !checkForEntry(memoType: "Written", uuID: uuid) {
                let text = Written(context: managedContext)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M-d-yyyy" //Your date format
                
                guard let relDate = releaseDate else {return}
                guard let date = dateFormatter.date(from: relDate) as NSDate? else {return}
                
                guard let cretDate = createdDate else {return}
                guard let createdDateString = dateFormatter.date(from: cretDate) as NSDate? else {return}
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                
                guard let relTime = releaseTime else {return}
                guard let time = timeFormatter.date(from: relTime) as NSDate? else {return}
                
                
                
                
                
                
                text.dateToBeReleased = date
                text.isVideo = false
                text.isVoiceMemo = false
                text.isWrittenMemo = true
                text.releaseTime = time
                text.memoText = memoText
                text.mileStone = writtenTag
                text.uuID = uuID
                text.creationDate = createdDateString
                
                if let texts = self.personPassed?.written?.mutableCopy() as? NSMutableOrderedSet {
                    texts.add(text)
                    self.personPassed?.written = texts
                }
                
                
                if relation == "undefined" {
                    
                    guard let userID = Auth.auth().currentUser?.uid else {return}
                    guard let theKey = key else {return}
                    let relationRef = Database.database().reference(withPath: "writtenMemos").child(userID).child(theKey)
                    
                    relationRef.updateChildValues(["relation":self.personPassed?.relation as Any])
                    
                    
                }
                
                
                do {
                    try managedContext.save()
                    cell.progressView.progress = 1.0
                    print(" I saved")
                    
                    
                    //self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    
                    managedContext.delete(text)
                    let errorAlert = UIAlertController(title: "This Memo Already Exists!", message: "You already have this memo!", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    print("THIS EXISTS: \(text.uuID)")
                    
                }
            } else {
                let errorAlert = UIAlertController(title: "This Memo Already Exists!", message: "You already have this memo!", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            
            
            
            
        default:
            print("there is nothing")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        title = "Downloads"
        configureAppBar()
        appBar.navigationBar.tintColor = .white
         self.appBar.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let lovedOnesName = personPassed?.name else {return}
        
        switch selectedMemoTypePassed {
        case "video":
            ref = Database.database().reference(withPath: "videos")
            let videoRef = ref?.child(userID)
            let query = videoRef?.queryOrdered(byChild: "lovedOne").queryEqual(toValue: lovedOnesName)
            
            query?.observe(.value) { (snapshot) in
                var newVideos: [VideosFromDatabase] = []
                
                for child in snapshot.children {
                    // 4
                    if let snapshot = child as? DataSnapshot,
                        let videoItem = VideosFromDatabase(snapshot: snapshot) {
                        newVideos.append(videoItem)
                    }
                }
                
                self.videosToDownload = newVideos
                self.tableView.reloadData()
                
            }
            
        case "audio":
            ref = Database.database().reference(withPath: "audioMemos")
            let audioRef = ref?.child(userID)
            let query = audioRef?.queryOrdered(byChild: "lovedOne").queryEqual(toValue: lovedOnesName)
            
            query?.observe(.value) { (snapshot) in
                var newAudios: [VoicesFromDatabase] = []
                
                for child in snapshot.children {
                    // 4
                    if let snapshot = child as? DataSnapshot,
                        let audioItem = VoicesFromDatabase(snapshot: snapshot) {
                        newAudios.append(audioItem)
                    }
                }
                
                self.voicesToDownload = newAudios
                self.tableView.reloadData()
                
            }
            
        case "text":
            
            ref = Database.database().reference(withPath: "writtenMemos")
            let writtenRef = ref?.child(userID)
            let query = writtenRef?.queryOrdered(byChild: "lovedOne").queryEqual(toValue: lovedOnesName)
            
            query?.observe(.value) { (snapshot) in
                var newTexts: [WrittenFromDatabase] = []
                
                for child in snapshot.children {
                    // 4
                    if let snapshot = child as? DataSnapshot,
                        let writtenItem = WrittenFromDatabase(snapshot: snapshot) {
                        newTexts.append(writtenItem)
                    }
                }
                
                self.textMemosToDownload = newTexts
                self.tableView.reloadData()
                
            }
            
        default:
            print("No data")
        }
        
        
        
       
        
       
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You haven't uploaded any memos yet!"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let str = ""
//        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
//        return NSAttributedString(string: str, attributes: attrs)
//    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "twotone_account_circle_black_48pt")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor {
        return UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
        
    }
    
    
//    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
//        let str = "Tap Me To Create A Loved One"
//        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout), NSAttributedStringKey.foregroundColor: UIColor.white]
//        
//        return NSAttributedString(string: str, attributes: attrs)
//    }
//    
//    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
//        /*let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
//         ac.addAction(UIAlertAction(title: "Hurray", style: .default))
//         present(ac, animated: true)
//         */
//        
//        performSegue(withIdentifier: "createLovedOne", sender: self)
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch selectedMemoTypePassed {
        case "video":
            return videosToDownload.count
             case "audio":
            return voicesToDownload.count
            case "text":
            
            return textMemosToDownload.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "downloads", for: indexPath) as! DownloadTableViewCell 

        // Configure the cell...
        
       
        
        switch selectedMemoTypePassed {
        case "video":
            let someText = videosToDownload[indexPath.row]
            
            let someTextTo = someText.videoOnDeviceURL
             
             cell.fileNameLabel.text = someTextTo
             
             return cell
        case "audio":
            let someText = voicesToDownload[indexPath.row]
            
            let someTextTo = someText.audioStorageURL
            
            cell.fileNameLabel.text = someTextTo
            
            return cell
        case "text":
            
            let someText = textMemosToDownload[indexPath.row]
            
            let someTextTo = someText.releaseDate
            
            cell.fileNameLabel.text = someTextTo
            
            return cell
        default:
            return cell
        }
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
       downLoadMemos(indexPath: indexPath)
       
//       cell.progressView.addSubview(progressIndicatorView)
//        cell.progressView.addConstraints(NSLayoutConstraint.constraints(
//            withVisualFormat: "V:|[v]|", options: .init(rawValue: 0),
//            metrics: nil, views: ["v": progressIndicatorView]))
//        cell.progressView.addConstraints(NSLayoutConstraint.constraints(
//            withVisualFormat: "H:|[v]|", options: .init(rawValue: 0),
//            metrics: nil, views:  ["v": progressIndicatorView]))
//        progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DownLoadsTableViewController {
    
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
