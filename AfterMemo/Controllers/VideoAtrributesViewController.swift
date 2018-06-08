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

class VideoAtrributesViewController: FormViewController {

    var passedVideoURL: String = ""
    var selectedPerson: Recipient?
    var passedVideo: Videos?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< TextRow(){ row in
                row.title = "Video Tag"
                row.placeholder = "Enter a name"
                row.tag = "videoTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
        }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
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
                    
                    guard let videoTagRow: TextRow = self?.form.rowBy(tag: "videoTag") else {
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
                    
                    
                    
                    uploadLink.putFile(from: videoURLForUpload, metadata: nil) { (metadatas, error) in
                        if error != nil {
                            print("This video could not load!")
                            return
                        } else {
                            
                            uploadLink.downloadURL(completion: { (url, error) in
                                
                                if error != nil {
                                    
                                    print("Failure to grab url")
                                    return
                                } else {
                                let dataBasePath = Database.database().reference().child("videos").child(userID).childByAutoId()
                                    
                                    guard let videoURLString = url?.absoluteString else {return}
                                    
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                
                                    dataBasePath.updateChildValues(["videoStorageURL": videoURLString,"videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString], withCompletionBlock: { (error, ref) in
                                        if error != nil {
                                            print("failed to update Database")
                                            return
                                        }
                                    })
                                    
                                }
                            })
                            
                        }
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
