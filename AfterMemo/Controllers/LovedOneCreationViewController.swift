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
import MaterialComponents
import Contacts

class LovedOneCreationViewController: FormViewController, grabbedContactInfoDelegate   {
    func didChoose(name: String, email: String, number: String, photo: Data, birthday: Date) {
        guard let nameRow: TextRow = self.form.rowBy(tag: "lovedOneName") else {return}
        nameRow.value = name
        
        guard let avatarRow: ImageRow = self.form.rowBy(tag: "lovedOnePicture") else {return}
        
        avatarRow.value = UIImage(data: photo)
        
      
        
        guard let birthdayRow: DateRow = self.form.rowBy(tag: "birthdayDateTag") else {return}
        
        birthdayRow.value = birthday
        
       
        
        guard let emailRow: EmailRow = self.form.rowBy(tag: "email") else {return}
        
        emailRow.value = email
        
        self.tableView.reloadData()
    }
    
   
    
  
    
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
        
        //        appBar.headerViewController.layoutDelegate = self
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    let contactItem = UIBarButtonItem(title: "Import Contact", style: .plain, target: self, action: #selector(showContactList))
    
    @objc func showContactList(){
        
        guard let contactNavigationController = storyboard?.instantiateViewController(withIdentifier: "contactsNavigator") as? UINavigationController else {return}
        
        guard let contactController = contactNavigationController.viewControllers.first as? ContactsTableViewController else {return}
        
        self.present(contactNavigationController, animated: true) {
            contactController.grabbedContactDelegate = self
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppBar()
        title = "Add"
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        self.appBar.navigationBar.tintColor = .white
       
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//        
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        self.appBar.navigationBar.rightBarButtonItems = [self.contactItem]
        
        
        
        
        
        form +++ Section()
            
            <<< TextRow(){ row in
                row.title = "Name Of Loved One"
                row.placeholder = "Enter a Name"
                row.tag = "lovedOneName"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< EmailRow(){ row in
                row.title = "Loved One's Email"
                row.placeholder = "email@gmail.com"
                row.tag = "email"
                row.add(rule: RuleEmail())
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< ImageRow() { row in
                row.title = "Image of Loved One"
                row.tag = "lovedOnePicture"
                row.allowEditor = true
                row.useEditedImage = true
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
                    
                    guard let emailRow: EmailRow = self?.form.rowBy(tag: "email") else {return}
                    
                    guard let emailRowValue = emailRow.value else {return}
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        
                        self?.save(recipientName: nameRowValue, avatar: avatarRowValue, birthday: birthDayRowValue, email: emailRowValue)
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }

        // Do any additional setup after loading the view.
    }


    }
    
    
    

    func save(recipientName: String, avatar: UIImage, birthday: Date, email: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
      
       
        
        do {
            
                
            let person = Recipient(context: managedContext)
                
                guard let savedImageData = UIImageJPEGRepresentation(avatar, 0.80) as NSData? else {return}
                
            
//                person.setValue(recipientName, forKey: "name")
//                person.setValue(savedImageData, forKey: "avatar")
//                person.setValue(birthday, forKey: "age")
                person.name = recipientName
                person.avatar = savedImageData
                person.age = birthday as NSDate
                person.email = email
            
                
            
                
                
                do {
                    try managedContext.save()
                    print(" I saved")
                    self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                    
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

extension LovedOneCreationViewController {
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



