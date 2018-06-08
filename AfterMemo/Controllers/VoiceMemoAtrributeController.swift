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

class VoiceMemoAtrributeViewController: FormViewController {
    var selectedPerson: Recipient?
    var audioURL: String = ""
    var sentVoiceMemo: VoiceMemos?
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
           
            <<< TextRow(){ row in
                row.title = "Audio Memo Tag"
                row.placeholder = "Enter a name"
                row.tag = "audioTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }.cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                })
            <<< DateRow() { row in
                row.title = "Date To Be Released"
                row.value = Date(timeIntervalSinceReferenceDate: 0)
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
                    
                    guard let auidoTagRow: TextRow = self?.form.rowBy(tag: "audioTag") else {return}
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
                    
                    uploadLink.putFile(from: audioFile, metadata: nil) { (metadata, error) in
                        if error != nil {
                            print("Could not upload voice memo")
                            return
                        } else {
                            uploadLink.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    print("url not available")
                                } else {
                                    let dataBasePath = Database.database().reference().child("audioMemos").child(userID).childByAutoId()
                                    
                                    guard let auidoURLString = url?.absoluteString else {return}
                                    
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                    
                                    dataBasePath.updateChildValues(["audioStorageURL": auidoURLString,"videoTag": audioTag, "releaseDate": dateString, "releaseTime": timeString], withCompletionBlock: { (error, ref) in
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


}

extension VoiceMemoAtrributeViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
