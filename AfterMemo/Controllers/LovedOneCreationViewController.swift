//
//  LovedOneCreationViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/28/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import CoreData

class LovedOneCreationViewController: FormViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        
        
        form +++ Section()
            
            <<< TextRow(){ row in
                row.title = "Name Of Loved One"
                row.placeholder = "Enter a Name"
                row.tag = "lovedOneName"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< ImageRow() { row in
                row.title = "Image of Loved One"
                row.tag = "lovedOnePicture"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< DateRow() { row in
                row.title = "Birthday"
                row.value = Date(timeIntervalSinceReferenceDate: 0)
                row.tag = "birthdayDateTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
        }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save"
                
                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = UIColor(red: 0.102, green: 0.5569, blue: 0, alpha: 1.0)
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                   
                    
                    guard let nameRow: TextRow = self?.form.rowBy(tag: "lovedOneName") else {return}
                    guard let nameRowValue = nameRow.value else {return}
                    
                    guard let avatarRow: ImageRow = self?.form.rowBy(tag: "lovedOnePicture") else {return}
                    
                    guard let avatarRowValue = avatarRow.value else {return}
                    
                    guard let birthdayRow: DateRow = self?.form.rowBy(tag: "birthdayDateTag") else {return}
                    
                    guard let birthDayRowValue = birthdayRow.value else {return}
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                        self?.save(recipientName: nameRowValue, avatar: avatarRowValue, birthday: birthDayRowValue)
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }

        // Do any additional setup after loading the view.
    }


    }
    

    func save(recipientName: String, avatar: UIImage, birthday: Date){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
      
        
        do {
            
                
            let person = Recipient(context: managedContext)
                
                guard let savedImageData = UIImageJPEGRepresentation(avatar, 0.80) as NSData? else {return}
                
            
                person.setValue(recipientName, forKey: "name")
                person.setValue(savedImageData, forKey: "avatar")
                person.setValue(birthday, forKey: "age")
            
                
            
                
                
                do {
                    try managedContext.save()
                    print(" I saved")
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
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
