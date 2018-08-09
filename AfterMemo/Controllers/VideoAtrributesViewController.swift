//
//  VideoAtrributesViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/20/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

// TODO: - Here we will allow the user to add tags to their videos and to add the dates and times for their videos or voice memos to be released.


import UIKit
import Eureka
import CoreData
import ImageRow
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MaterialComponents

class VideoAtrributesViewController: FormViewController {
var appBar = MDCAppBar()
    let memoHeaderView = GeneralHeaderView()
    
    func configureAppBar(){
        self.addChildViewController(appBar.headerViewController)
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
    var passedVideoURL: String = ""
    var selectedPerson: Recipient?
    var passedVideo: Videos?
    var triggers = Triggers()
    
     //let uuid = UUID().uuidString
    @IBOutlet weak var progressReport: CircularLoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressReport.translatesAutoresizingMaskIntoConstraints = false
        
        configureAppBar()
        appBar.navigationBar.tintColor = .white
        
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        form +++ Section()
            <<< PickerInlineRow<String>(){ row in
                row.title = "Release Trigger"
               row.options = triggers.triggerArray
                row.tag = "videoTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
        }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                })
        <<< DateRow() { row in
            row.title = "Date To Be Released"
            row.value = Date(timeIntervalSinceReferenceDate: 0)
            row.tag = "dateTag"
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            }                .cellUpdate({ (cell, row) in
                if !row.isValid {
                    cell.backgroundColor = UIColor.red
                }
            })

            <<< TimeRow() { row in
                row.title = "Enter the time for realease"
                row.value = Date()
                row.tag = "timeTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                }                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.backgroundColor = UIColor.red
                    }
                })

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save"
                
                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = UIColor(red: 0.102, green: 0.5569, blue: 0, alpha: 1.0)
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                    
                    guard let videoTagRow: PickerInlineRow<String> = self?.form.rowBy(tag: "videoTag") else {
                        print("fail 1")
                        return}
                    guard let videoTagRowValue = videoTagRow.value else {
                        print("fail 2")
                        return}
                    
                    guard let dateRow: DateRow = self?.form.rowBy(tag: "dateTag") else {
                        print("fail 3")
                        return
                    }
                    guard let dateRowValue = dateRow.value else {
                        print("fail 4")
                        return}
                    
                    guard let timeRow: TimeRow = self?.form.rowBy(tag: "timeTag") else {return}
                    guard let timeRowValue = timeRow.value else {
                        print("fail 5")
                        return}
                    
                   
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                        self?.view.bringSubview(toFront: (self?.progressReport)!)
                        
                        self?.save(videoTag: videoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, passedURL: (self?.passedVideoURL)!)
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
        // Do any additional setup after loading the view.
    }
    
    func save(videoTag: String, releaseDate: Date, releaseTime: Date, passedURL: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
  
        guard let currentVideo = passedVideo else {
            
            print("Didn't pass")
            return}
                currentVideo.videoTag = videoTag
                currentVideo.dateToBeReleased = releaseDate as NSDate
                currentVideo.releaseTime = releaseTime as NSDate
                let uuID = currentVideo.uuID
        guard let lovedOneEmail = selectedPerson?.email else {
            return
        }
                
                
                do {
                    try managedContext.save()
                    print(" I saved")
                    guard let userID = Auth.auth().currentUser?.uid else {return}
                    
                    let uploadLink = Storage.storage().reference().child(userID).child("videos").child(currentVideo.urlPath! + videoTag)

                    guard let videoURL = currentVideo.urlPath else {return}
                    let paths = NSSearchPathForDirectoriesInDomains(
                        FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                    let dataPath = documentsDirectory.appendingPathComponent(videoURL)
                    
                    guard let videoURLForUpload = URL(string: dataPath.absoluteString) else {return}
                    
                    
                    
                let uploadTask =  uploadLink.putFile(from: videoURLForUpload, metadata: nil) { (metadatas, error) in
                        if error != nil {
                            print("This video could not load!")
                            return
                        } else {
                            
                            uploadLink.downloadURL(completion: { (url, error) in
                                
                                if error != nil {
                                    
                                    print("Failure to grab url")
                                    let uploadError = UIAlertController(title: "Error!", message: "The download url could not be grabbed", preferredStyle: .alert)
                                    
                                    uploadError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    self.present(uploadError, animated: true, completion: nil)
                                    
                                    return
                                } else {
                                let dataBasePath = Database.database().reference().child("videos").child(userID).childByAutoId()
                                    
                                    guard let videoURLString = url?.absoluteString else {return}
                                    
                                    guard let creationDate = currentVideo.creationDate as Date? else {return}
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    
                                    let createdDateString = dateFormat.string(from: creationDate)
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                    
                                    guard let lovedOneName = self.selectedPerson?.name else {return}
                                
                                    dataBasePath.updateChildValues(["videoStorageURL": videoURLString,"videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": currentVideo.uuID, "videoOnDeviceURL":videoURL, "createdDate": createdDateString, "lovedOneEmail": lovedOneEmail], withCompletionBlock: { (error, ref) in
                                        if error != nil {
                                            print("failed to update Database")
                                            
                                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                                            
                                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                            
                                            self.present(databaseError, animated: true, completion: nil)
                                            return
                                        }else {
                                            
                                            let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                                            
                                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                                self.performSegue(withIdentifier: "backtoMain", sender: self)
                                            }))
                                            
                                            self.present(successAlert, animated: true, completion: nil)
                                            
                                            
                                        }
                                    })
                                    
                                }
                            })
                            
                        }
                    }
                    
                    uploadTask.observe(.progress) { (snapshot) in
                        // Upload reported progress
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                            / Double(snapshot.progress!.totalUnitCount)
                        
                        self.progressReport.progress = CGFloat(percentComplete)
                    }
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
        
       
        
       
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

extension VideoAtrributesViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }
}
