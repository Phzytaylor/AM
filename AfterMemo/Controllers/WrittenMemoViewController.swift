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
import FirebaseDatabase
import FirebaseAuth


class WrittenMemoViewController: FormViewController{
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
    
    @IBOutlet weak var loadingView: CircularLoaderView!
    let uuid = UUID().uuidString
    
    var selectedPerson: Recipient?
    
    var triggers = Triggers()
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true 
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Written Memo"
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        configureAppBar()
        appBar.navigationBar.tintColor = .white

//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        form +++ Section("Write a Memo for a loved one")
            <<< TextAreaRow(){row in
                row.title = "Write A Memo"
                row.placeholder = "Think of a future event such as a graduation, tell them how much you love them and how proud you are."
                row.tag = "memoText"
        }
        
       +++ Section("Add some details")
            <<< PickerInlineRow<String>(){ row in
                row.title = "Release Trigger"
                row.options = triggers.triggerArray
                row.tag = "memoTag"
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
                row.value = Date()
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
                row.value = Date()
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
                    
                    guard let memoTagRow: PickerInlineRow<String> = self?.form.rowBy(tag: "memoTag") else {return}
                    guard let memoTagRowValue = memoTagRow.value else {return}
                    guard let dateRow: DateRow = self?.form.rowBy(tag: "dateTag") else {
                        return
                    }
                    guard let dateRowValue = dateRow.value else {return}
                    
                    guard let timeRow: TimeRow = self?.form.rowBy(tag: "timeTag") else {return}
                    guard let timeRowValue = timeRow.value else {return}
                    
                    guard let memoTextRow: TextAreaRow = self?.form.rowBy(tag: "memoText") else {return}
                    
                    guard let memoTexRowValue = memoTextRow.value else {return}
                    
                    
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                        self?.save(memoTag: memoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, memoText: memoTexRowValue)
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func save(memoTag: String, releaseDate: Date, releaseTime: Date, memoText: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
       let written = Written(context: managedContext)
        
    guard let theSelectedPerson = selectedPerson else {return}
                
//            writtens.setValue(memoTag, forKey: "writtenTag")
//            writtens.setValue(releaseDate, forKey: "dateToBeReleased")
//            writtens.setValue(releaseTime, forKey: "releaseTime")
//        writtens.setValue(theSelectedPerson, forKey: "recipient")
//        writtens.setValue(false, forKey: "isVideo")
//        writtens.setValue(false, forKey: "isVoiceMemo")
//        writtens.setValue(true, forKey: "isWrittenMemo")
//            theSelectedPerson.setValue(writtens, forKey: "written")
        
        written.writtenTag = memoTag
        written.dateToBeReleased = releaseDate as NSDate
        written.releaseTime = releaseTime as NSDate
        written.isVideo = false
        written.isVoiceMemo = false
        written.isWrittenMemo = true
        written.memoText = memoText
        written.uuID = uuid
        written.creationDate = NSDate()
        
        if let writtens = theSelectedPerson.written?.mutableCopy() as? NSMutableOrderedSet {
            writtens.add(written)
            theSelectedPerson.latestMemoDate = NSDate()
            theSelectedPerson.written = writtens
        }
        
        
                do {
                    try managedContext.save()
                    print(" I saved")
                    loadingView.progress = 0.5
                       guard let userID = Auth.auth().currentUser?.uid else {return}
                    let dataBasePath = Database.database().reference().child("writtenMemos").child(userID).childByAutoId()
                    
                    guard let creationDate = written.creationDate as Date? else {return}
                   
                    
                    
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                    let dateString = dateFormat.string(from: releaseDate)
                    let createdDateString = dateFormat.string(from: creationDate)
                    
                    let timeFormat = DateFormatter()
                    
                    timeFormat.dateFormat = "h:mm a"
                    
                    let timeString = timeFormat.string(from: releaseTime)
                    
                    guard let lovedOneName = selectedPerson?.name else {return}
                    guard let lovedOneEmail = selectedPerson?.email else {return}
                    
                    dataBasePath.updateChildValues(["memoTag": memoTag, "releaseDate": dateString, "releaseTime": timeString, "memoText": memoText, "lovedOne" : lovedOneName, "uuID": uuid,"createdDate": createdDateString, "lovedOneEmail": lovedOneEmail]) { (error, ref) in
                        if error != nil {
                            print("Upload did not work")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }else{
                            
                            self.loadingView.progress = 1.0
                            
                            
                            let successAlert = UIAlertController(title: "Success", message: "Your written and it's attributes were uploaded successfully", preferredStyle: .alert)
                            
                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                 self.performSegue(withIdentifier: "fromWritten", sender: self)
                            }))
                            
                            self.present(successAlert, animated: true, completion: nil)
                            
                           
                        }
                    }
                    
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
