//
//  LovedOneSelectionTableViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/28/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import MobileCoreServices
import DZNEmptyDataSet
import MaterialComponents
import FirebaseDatabase
import FirebaseAuth

class LovedOneSelectionTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, NSFetchedResultsControllerDelegate {
    var mediaSelected = ""
    var fileName = ""
    var personsArray: [NSManagedObject] = []
    var selectedCellBeforeAlert: Int?
    var appBar = MDCAppBar()
    var videoToPass: Videos?
    var selectedMemoType = ""
    var newMemoDelegate: newMemoDelegate!
    let memoHeaderView = GeneralHeaderView()
    var passedContext: NSManagedObjectContext?
    var senderToBePassed: AnyObject?
    
    
   
    @IBAction func editLovedOneAction(_ sender: AnyObject) {
        
        guard let cell = sender.superview?.superview as? LovedOnesTableViewCell else {
            return // or fatalError() or whatever
        }
        let indexPath = self.tableView.indexPath(for: cell)
        
        selectedCellBeforeAlert = indexPath?.row
        
        self.performSegue(withIdentifier: "editLovedOne", sender: self)
       
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
        
      headerView.trackingScrollView = self.tableView
        
        appBar.addSubviewsToParent()
        
//        appBar.headerViewController.layoutDelegate = self
        
        
    }
   
    @objc func createNewLovedOne() {
        performSegue(withIdentifier: "createLovedOne", sender: self)
    }
    
    
    func deleteLovedOne(currentLovedOne: Recipient, indexPathRow: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var movieArray: [String] = [String]()
        var voiceArray: [String] = [String]()
        var textArray: [String] = [String]()
        var managedContext: NSManagedObjectContext!
        
        if let movies = currentLovedOne.videos?.array as? [Videos]{
            
            for video in movies {
                guard let uuid = video.uuID else {
                    continue
                }
                
                movieArray.append(uuid)
            }
        }
        
        
        if let voice = currentLovedOne.voice?.array as? [VoiceMemos]{
            
            for voices in voice {
                guard let uuid = voices.uuID else {
                    continue
                }
                
                voiceArray.append(uuid)
            }
        }
        
        if let text = currentLovedOne.written?.array as? [Written]{
            
            for texts in text {
                guard let uuid = texts.uuID else {
                    continue
                }
                
                textArray.append(uuid)
            }
        }

        context.delete(currentLovedOne)
        appDelegate.saveContext()
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        for vidID in movieArray {
            
            let dataBasePath = Database.database().reference().child("videos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: vidID)
            
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {continue}
                    //TODO: NEED TO MAKE THIS CHANGE TO ALL UPDATES ^^^^
                    
                    let editAtPath = Database.database().reference().child("videos").child(userID).child(key)
                    
                    editAtPath.removeValue()
                   
                }
                
                
            }
        }
        
        
        for voiceID in voiceArray {
            
            let dataBasePath = Database.database().reference().child("audioMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: voiceID)
            
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {continue}
                    //TODO: NEED TO MAKE THIS CHANGE TO ALL UPDATES ^^^^
                    
                    let editAtPath = Database.database().reference().child("audioMemos").child(userID).child(key)
                    
                    editAtPath.removeValue()
                    
                }
                
                
            }
        }
        
        
        for textID in textArray {
            
            let dataBasePath = Database.database().reference().child("writtenMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: textID)
            
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {continue}
                    //TODO: NEED TO MAKE THIS CHANGE TO ALL UPDATES ^^^^
                    
                    let editAtPath = Database.database().reference().child("writtenMemos").child(userID).child(key)
                    
                    editAtPath.removeValue()
                    
                }
                
                
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.reloadData()
    }
    
    lazy var fetchedRC: NSFetchedResultsController<Recipient> = {
        
        
        
        let fetchRequest:NSFetchRequest<Recipient> = Recipient.fetchRequest()
        
       
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:managedContext , sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchedResultsController.delegate = self
        
        
        
        return fetchedResultsController
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
       configureAppBar()
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.appBar.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        title = "Loved Ones"
        
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
       
        let rightButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "baseline_add_white_24pt"), style: .plain, target: self, action: #selector(self.createNewLovedOne))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let recipientFetch: NSFetchRequest<Recipient> = Recipient.fetchRequest()
       
        
        do {
//           personsArray = try managedContext.fetch(recipientFetch)
            
           try fetchedRC.performFetch()
           
           
                
        } catch let error as NSError {
            print("Could not find videos: \(error), \(error.userInfo)")
        }

            
        }
    
    func saveRelation(lovedOne: Recipient, media:String){
        let addRelationAlert = UIAlertController(title: "No Relation Set", message: "You haven't set a relation for this person Yet", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Update Relation", style: .default) { (alertAction) in
            let textField = addRelationAlert.textFields![0] as UITextField
            
            guard let relationText = textField.text else {
                return
            }
            
            if relationText.isEmpty {
                
                print("Can't save")
                
                let emptyAlert = UIAlertController(title: "Error", message: "You must enter a relation", preferredStyle: .alert)
                
                let emptyAlertAction = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                    
                    self.present(addRelationAlert, animated: true, completion: nil)
                    
                })
                
                emptyAlert.addAction(emptyAlertAction)
                
                self.present(emptyAlert, animated: true, completion: nil)
                
            } else {
                print("Time to save")
                
                lovedOne.relation = relationText
                
                do {
                    try lovedOne.managedObjectContext?.save()
                    
                    switch media {
                    case "audio":
                         self.performSegue(withIdentifier: "newAudioMemo", sender: self)
                    case "video":
                        self.performSegue(withIdentifier: "videoAtributes", sender: self)
                    case "written":
                        self.performSegue(withIdentifier: "toWrittenMemo", sender: self)
                    default:
                        print("oops")
                    }
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addRelationAlert.addTextField { (textField) in
            textField.placeholder = "Enter your relation to \(lovedOne.name ?? "them")"
        }
        
        addRelationAlert.addAction(action)
        addRelationAlert.addAction(cancelAction)
        
        self.present(addRelationAlert, animated: true, completion: nil)
        
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You haven't created any loved ones yet, but you can in just a few seconds!"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap Below To Add A Loved One"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "twotone_account_circle_black_48pt")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor {
        return UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
        
    }
    
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Tap Me To Create A Loved One"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        /*let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "Hurray", style: .default))
         present(ac, animated: true)
         */
        
        performSegue(withIdentifier: "createLovedOne", sender: self)
    }

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
        let count = fetchedRC.fetchedObjects?.count ?? 0
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lovedOnes", for: indexPath) as! LovedOnesTableViewCell
        let lovedOne = fetchedRC.object(at: IndexPath(row: indexPath.row, section: 0))
        guard let lovedOneImage = lovedOne.value(forKey: "avatar") as? Data else {return cell}
        guard let lovedOneName = lovedOne.value(forKey: "name") as? String else {
            return cell
        }
        
        cell.avatarImageView.image = UIImage(data: lovedOneImage)
        cell.nameLabel.text = lovedOneName

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lovedOne = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
        
        if mediaSelected == "audio"{
             selectedCellBeforeAlert = indexPath.row
            
            if lovedOne.relation == nil {
                saveRelation(lovedOne: lovedOne, media: mediaSelected)
                
            } else {
                self.performSegue(withIdentifier: "newAudioMemo", sender: self)
            }
            
            
            

            
            
        } else if mediaSelected == "video" {
            selectedCellBeforeAlert = indexPath.row
            //VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
            
            if lovedOne.relation == nil {
                saveRelation(lovedOne: lovedOne, media: mediaSelected)
                
            } else {
            
                self.performSegue(withIdentifier: "videoAtributes", sender: self)
                
            }
            
        } else if mediaSelected == "written" {
             selectedCellBeforeAlert = indexPath.row
            
            if lovedOne.relation == nil {
            
                saveRelation(lovedOne: lovedOne, media: mediaSelected)
                
            } else {
            
                self.performSegue(withIdentifier: "toWrittenMemo", sender: self)
                
            }
            
        } else if mediaSelected == "none" {
              selectedCellBeforeAlert = indexPath.row
            self.performSegue(withIdentifier: "showMemos", sender: self)
        } else if mediaSelected == "downloads" {
            selectedCellBeforeAlert = indexPath.row
            
            let downloadSelection = UIAlertController(title: "Choose One", message: "Selected Which Kind Of Memo You Want To Download", preferredStyle: .actionSheet)
            
            downloadSelection.addAction(UIAlertAction(title: "Video Memos", style: .default, handler: { (Action) in
                
                self.selectedMemoType = "video"
                self.performSegue(withIdentifier: "toDownloads", sender: self)
            }))
            
            downloadSelection.addAction(UIAlertAction(title: "Voice Memos", style: .default, handler: { (Action) in
                self.selectedMemoType = "audio"
                self.performSegue(withIdentifier: "toDownloads", sender: self)
                
            }))
            
            downloadSelection.addAction(UIAlertAction(title: "Text Memos", style: .default, handler: { (Action) in
                self.selectedMemoType = "text"
                self.performSegue(withIdentifier: "toDownloads", sender: self)
            }))
            
            downloadSelection.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(downloadSelection, animated: true, completion: nil)
            
            
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let lovedOne = fetchedRC.object(at: IndexPath(row: indexPath.row, section: 0))
           
            deleteLovedOne(currentLovedOne: lovedOne, indexPathRow: indexPath.row)
            tableView.reloadData()
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("I inserted")
            
            tableView.reloadSections([0], with: .fade)
            break;
        case .delete:
            print("I deleted")
            guard let numberOfPeople = tableView?.numberOfRows(inSection: 0) else{
                return
            }
            
            
            tableView?.performBatchUpdates({
                if numberOfPeople > 1 {
                    for i in (0...numberOfPeople - 1).reversed() {
                        
                        tableView?.deleteRows(at: [IndexPath(item: i, section: 0)], with: .fade)
                    }
                    let count = fetchedRC.fetchedObjects?.count ?? 0
                    
                    for items in 0...count - 1 {
                        
                        tableView?.insertRows(at: [IndexPath(item: items, section: 0)], with: .fade)
                    }
                    
                } else{
                    
                    tableView.reloadSections([0], with: .fade)
                }
                
                
                
                
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                //                }
            }, completion: nil)
            break;
        case . update:
            print("I updated")
            
            guard let numberOfPeople = tableView?.numberOfRows(inSection: 0) else{
                return
            }
            
            
            tableView?.performBatchUpdates({
                if numberOfPeople > 1 {
                    for i in (0...numberOfPeople - 1).reversed() {
                        
                        tableView?.deleteRows(at: [IndexPath(item: i, section: 0)], with: .fade)
                    }
                    let count = fetchedRC.fetchedObjects?.count ?? 0
                    
                    for items in 0...count - 1 {
                        
                        tableView?.insertRows(at: [IndexPath(item: items, section: 0)], with: .fade)
                    }
                    
                } else{
                    
                    tableView.reloadSections([0], with: .fade)
                }
                
                
                
                
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                //                }
            }, completion: nil)
            
            
            break;
        case .move:
            print("I moved")
            guard let numberOfPeople = tableView?.numberOfRows(inSection: 0) else{
                return
            }
            
            tableView?.performBatchUpdates({
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                if numberOfPeople > 1 {
                    for i in (0...numberOfPeople - 1).reversed() {
                        
                        tableView?.deleteRows(at: [IndexPath(item: i, section: 0)], with: .fade)
                    }
                    let count = fetchedRC.fetchedObjects?.count ?? 0
                    if count > 1 {
                        for items in 0...count - 1 {
                            
                            tableView?.insertRows(at: [IndexPath(item: items, section: 0)], with: .fade)
                        }
                        
                    }
                    
                }else  {
                    
                    tableView.reloadSections([0], with: .fade)
                }
                
            }, completion: nil)
            
            break;
        default:
            print("I don't know")
        }
        
        
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        guard  let indexPath = self.tableView.indexPathForSelectedRow else {
//            print("I am not working")
//            return}
        if segue.identifier == "createLovedOne" {
            guard let destinationVC = segue.destination as? LovedOneCreationViewController else {
                return
            }
            
            destinationVC.passedSender = UIButton.self
        }else {
        guard let person = selectedCellBeforeAlert else {
            print(" I AM THE BAD var")
            return}
        
      
        
        if segue.identifier == "newAudioMemo" {
            
          //  guard let desitnationVC = segue.destination as? RecordingViewController else {return}
            
            guard let desitnationVC = segue.destination as? VoiceMemoAtrributeViewController else {return}
            
            desitnationVC.selectedPerson = fetchedRC.object(at: IndexPath(item: person, section: 0))
            
            desitnationVC.passedSender = sender
            
        } else if segue.identifier == "videoAtributes" {
            
            if segue.identifier == "videoAtributes" {
                print("True")
            }
            
            guard let desitnationVC = segue.destination as? VideoAtrributesViewController else {return}
            
            desitnationVC.selectedPerson = fetchedRC.object(at: IndexPath(item: person, section: 0))
            print(fetchedRC.object(at: IndexPath(item: person, section: 0)))
            desitnationVC.passedSender = sender
            
            //desitnationVC.passedVideo = videoToPass
            
//            print("THE PASSED \(videoToPass)")
            
            
        }  else if segue.identifier == "toWrittenMemo"{
            
            guard let desitnationVC = segue.destination as? WrittenMemoViewController else {return}
            
            desitnationVC.selectedPerson = fetchedRC.object(at: IndexPath(item: person, section: 0))
            
            desitnationVC.passedSender = sender
            
        } else if segue.identifier == "showMemos" {
            guard let destinationVC = segue.destination as? MemoListViewController else {return}
            
            //print(personsArray[person] as? Recipient)
            
            destinationVC.passedRecipient = fetchedRC.object(at: IndexPath(item: person, section: 0))
        } else if segue.identifier == "toDownloads" {
            
            guard let desitnationVC = segue.destination as? DownLoadsTableViewController else {return}
            
            desitnationVC.personPassed = fetchedRC.object(at: IndexPath(item: person, section: 0))
            desitnationVC.selectedMemoTypePassed = selectedMemoType
        }
        else if segue.identifier == "editLovedOne" {
            guard let destinationVC = segue.destination as? LovedOneCreationViewController else {
                  return}
            destinationVC.passedSender = sender
            print(" I AM THE SENDER: \(sender)")
            destinationVC.passedPerson = fetchedRC.object(at: IndexPath(item: person, section: 0))
            

            
        }
        }
    }
    
    
    
    func save(url:String, _ tempFilePath: URL){

        guard let cellSelected = selectedCellBeforeAlert else {
            print("There was no selection")
            return
        }
        print("THe SELECTED CELL: \(cellSelected)")
        
        let selectedPerson = fetchedRC.object(at: IndexPath(item: cellSelected, section: 0))
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
//
//      let managedContext = appDelegate.persistentContainer.viewContext
   
        
        guard let currentContext = selectedPerson.managedObjectContext else {
            print("I AM NOT SET")
            return
        }
        
        let video = Videos(context: currentContext)
        
        
        videoToPass = video
        
        guard let savedImage = previewImageForLocalVideo(url: tempFilePath) else {
            return
        }
        let savedImageData = savedImage.pngData() as NSData?
        let uuid = UUID().uuidString
        
        video.thumbNail = savedImageData
        video.urlPath = url
        video.isVideo = true
        video.isVoiceMemo = false
        video.isWrittenMemo = false
        video.uuID = uuid
        video.creationDate = NSDate()
        
        
        if let videos = selectedPerson.videos?.mutableCopy() as? NSMutableOrderedSet {
            videos.add(video)
            selectedPerson.latestMemoDate = NSDate()
           
            //selectedPerson.videos = videos
            selectedPerson.addToVideos(videos)
            
            
            
        }
        
        let addAtributesAlert = UIAlertController(title: "Add Now?", message: "Would you like to add detials to the video?", preferredStyle: .alert)
        
        addAtributesAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "videoAtributes", sender: LovedOneSelectionTableViewController())
        }))
        
       
        
        addAtributesAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        do {
            //try currentContext.save()
//            try selectedPerson.managedObjectContext?.save()
//            try video.managedObjectContext?.save()
            try currentContext.save()
            
            
            
            print("THIS IS THE SELECTED PERSON: \(selectedPerson)")
            print("I saved")
            
            self.tableView.reloadData()
            DispatchQueue.main.async {
                
                
                self.present(addAtributesAlert, animated: true, completion: {
                    
                })
                
               // self.present(addAtributesAlert, animated: true, completion: nil)
            }
            
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

}


extension LovedOneSelectionTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

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
                let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
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
            
            
            
            
        }
        
        nameFileAlert.addAction(saveAction)
        
        
        self.present(nameFileAlert, animated: true, completion: nil)
    }
    
}

extension LovedOneSelectionTableViewController: UINavigationControllerDelegate{}
extension LovedOneSelectionTableViewController: AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension LovedOneSelectionTableViewController {
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








// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
