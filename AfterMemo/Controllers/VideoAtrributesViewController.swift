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

class VideoAtrributesViewController: FormViewController {

    var passedVideoURL: String = ""
    var selectedPerson: Recipient?
    
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
                    
                    guard let videoTagRow: TextRow = self?.form.rowBy(tag: "videoTag") else {return}
                    guard let videoTagRowValue = videoTagRow.value else {return}
                    guard let dateRow: DateRow = self?.form.rowBy(tag: "dateTag") else {
                        return
                    }
                    guard let dateRowValue = dateRow.value else {return}
                    
                    guard let timeRow: TimeRow = self?.form.rowBy(tag: "timeTag") else {return}
                    guard let timeRowValue = timeRow.value else {return}
                    
                   
                    
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
        
        let VideoFetch: NSFetchRequest<Videos> = Videos.fetchRequest()
        VideoFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Videos.urlPath),
                                         passedURL)
        
        do {
            let results = try managedContext.fetch(VideoFetch)
            if results.count > 0 {
                
                guard  let currentVideo = results.first else {return}
                
                
                currentVideo.setValue(videoTag, forKey: "videoTag")
                currentVideo.setValue(releaseDate, forKey: "dateToBeReleased")
                currentVideo.setValue(releaseTime, forKey: "releaseTime")
                
                
                do {
                    try managedContext.save()
                    print(" I saved")
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            else{
                //oh well
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            
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
