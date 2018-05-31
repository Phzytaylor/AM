//
//  WrittenMemoViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/28/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import CoreData
import MaterialComponents


class WrittenMemoViewController: FormViewController{
var appBar = MDCAppBar()
    var selectedPerson: Recipient?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true 
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Voice Memo"

        self.addChildViewController(appBar.headerViewController)
        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
        appBar.addSubviewsToParent()
        
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        form +++ Section("Write a Memo for a loved one")
            <<< TextAreaRow(){row in
                row.title = "Write A Memo"
                row.placeholder = "Think of a future event such as a graduation, tell them how much you love them and how proud you are."
        }
        
       +++ Section("Add some details")
            <<< TextRow(){ row in
                row.title = "Memo Tag"
                row.placeholder = "Enter a name"
                row.tag = "memoTag"
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
                    
                    guard let memoTagRow: TextRow = self?.form.rowBy(tag: "memoTag") else {return}
                    guard let memoTagRowValue = memoTagRow.value else {return}
                    guard let dateRow: DateRow = self?.form.rowBy(tag: "dateTag") else {
                        return
                    }
                    guard let dateRowValue = dateRow.value else {return}
                    
                    guard let timeRow: TimeRow = self?.form.rowBy(tag: "timeTag") else {return}
                    guard let timeRowValue = timeRow.value else {return}
                    
                    
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                       self?.save(memoTag: memoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue)
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func save(memoTag: String, releaseDate: Date, releaseTime: Date){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Written", in: managedContext)!
        
        let writtens = NSManagedObject(entity: entity, insertInto: managedContext)
        
    guard let theSelectedPerson = selectedPerson else {return}
                
            writtens.setValue(memoTag, forKey: "writtenTag")
            writtens.setValue(releaseDate, forKey: "dateToBeReleased")
            writtens.setValue(releaseTime, forKey: "releaseTime")
        writtens.setValue(theSelectedPerson, forKey: "recipient")
        writtens.setValue(false, forKey: "isVideo")
        writtens.setValue(false, forKey: "isVoiceMemo")
        writtens.setValue(true, forKey: "isWrittenMemo")
            theSelectedPerson.setValue(writtens, forKey: "written")
        
                do {
                    try managedContext.save()
                    print(" I saved")
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
           
            
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension WrittenMemoViewController {
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
