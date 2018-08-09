//
//  VoiceMemoAtrributeController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/21/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import ImageRow
import CoreData
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MaterialComponents

class VoiceMemoAtrributeViewController: FormViewController {
    var selectedPerson: Recipient?
    var audioURL: String = ""
    var sentVoiceMemo: VoiceMemos?
     let uuid = UUID().uuidString
    var triggers = Triggers()
    
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
    @IBOutlet weak var progressView: CircularLoaderView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppBar()
        appBar.navigationBar.tintColor = .white
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
    progressView.translatesAutoresizingMaskIntoConstraints = false
        form +++ Section()
           
            <<< PickerInlineRow<String>(){ row in
                row.title = "Release Trigger"
                row.options = triggers.triggerArray
                row.tag = "audioTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }.cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                })
            <<< DateRow() { row in
                row.title = "Date To Be Released"
                row.value = Date()
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.tag = "dateTag"
                }  .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.backgroundColor = UIColor.red
                    }
                })
            <<< TimeRow() { row in
                row.title = "Enter the time for realease"
                row.value = Date()
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.tag = "timeTag"
                
                }  .cellUpdate({ (cell, row) in
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
                    
                    guard let auidoTagRow: PickerInlineRow<String> = self?.form.rowBy(tag: "audioTag") else {return}
                    guard let audioTagRowValue = auidoTagRow.value else {return}
                    guard let dateRow: DateRow = self?.form.rowBy(tag: "dateTag") else {
                        return
                    }
                    guard let dateRowValue = dateRow.value else {return}
                    
                    guard let timeRow: TimeRow = self?.form.rowBy(tag: "timeTag") else {return}
                    guard let timeRowValue = timeRow.value else {return}
                    
                    
                    
                    
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                        if self?.audioURL == nil || self?.audioURL == "" {
                            
                            self?.save(audioTag: audioTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, passedURL: (self?.audioURL)!)
                            
                        } else {
                        
                            self?.save(audioTag: audioTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, passedURL: (self?.audioURL)!)
                            
                        }
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
}
    
    
    
    
    func save(audioTag: String, releaseDate: Date, releaseTime: Date, passedURL: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        guard let currentaudio = sentVoiceMemo else {
            print("The voice memo did not pass")
            return}
        
              
                currentaudio.audioTag = audioTag
                currentaudio.dateToBeReleased = releaseDate as NSDate
                currentaudio.releaseTime = releaseTime as NSDate
                currentaudio.uuID = uuid
                
                
//                currentaudio.setValue(audioTag, forKey: "audioTag")
//                currentaudio.setValue(releaseDate, forKey: "dateToBeReleased")
//                currentaudio.setValue(releaseTime, forKey: "releaseTime")
                
                do {
                    try managedContext.save()
                    print(" I saved")
                    
                    guard let audioURL = currentaudio.urlPath else {return}
                    
                    let audioFile = self.getDocumentsDirectory().appendingPathComponent(audioURL)
                    
                    guard let userID = Auth.auth().currentUser?.uid else {return}
                    
                    let uploadLink = Storage.storage().reference().child(userID).child("voiceMemos").child(audioURL + audioTag)
                    
                   let uploadTask = uploadLink.putFile(from: audioFile, metadata: nil) { (metadata, error) in
                        if error != nil {
                            print("Could not upload voice memo")
                            return
                        } else {
                            uploadLink.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    print("url not available")
                                    
                                    let uploadError = UIAlertController(title: "Error!", message: "The download url could not be grabbed", preferredStyle: .alert)
                                    
                                    uploadError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    self.present(uploadError, animated: true, completion: nil)
                                    
                                } else {
                                    let dataBasePath = Database.database().reference().child("audioMemos").child(userID).childByAutoId()
                                    
                                    guard let auidoURLString = url?.absoluteString else {return}
                                    
                                     guard let creationDate = currentaudio.creationDate as Date? else {return}
                                    
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    let createdDateString = dateFormat.string(from: creationDate)
                                    
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                    
                                    guard let lovedOneName = self.selectedPerson?.name else {return}
                                    guard let lovedOneEmail = self.selectedPerson?.email else {return}
                                    
                                    dataBasePath.updateChildValues(["audioStorageURL": auidoURLString,"audioTag": audioTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": self.uuid, "audioOnDeviceURL": audioURL,"createdDate": createdDateString, "lovedOneEmail": lovedOneEmail], withCompletionBlock: { (error, ref) in
                                        if error != nil {
                                            
                                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                                            
                                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                            
                                            self.present(databaseError, animated: true, completion: nil)
                                            
                                            print("failed to update Database")
                                            return
                                        } else {
                                            
                                            
                                            
                                            let successAlert = UIAlertController(title: "Success", message: "Your voice memo and it's attributes were uploaded successfully", preferredStyle: .alert)
                                            
                                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                                self.performSegue(withIdentifier: "done", sender: self)
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
                        
                        self.progressView.progress = CGFloat(percentComplete)
                    }
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            
        
        
        
        
    }


}

extension VoiceMemoAtrributeViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
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
