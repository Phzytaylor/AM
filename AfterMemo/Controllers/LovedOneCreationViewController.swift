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
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

//TODO: Need to grab all of the memos under this loved one from coredata before saving any changes. Then when saving is done the values will be changed in the database which can be found by the UUID in each of the memos.

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
    
    func alertFunction(titleText:String, bodyText:String){
        let alertView = UIAlertController(title: titleText, message: bodyText, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func uploadMedia(avatar: UIImage, name:String,userID: String,completion: @escaping (_ url: String?) -> Void) {
        let storageRef = Storage.storage().reference().child(userID).child(name).child("avatar")
        
        let jpegRep = avatar.jpegData(compressionQuality: 0.30)!
        let imagetoLoad = UIImage(data: jpegRep)
        
        if let uploadData = imagetoLoad?.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        if error == nil {
                            completion(url?.absoluteString)
                        }
                    })

                }
            }
        }
        
    }
  
  
var uuidVideoArray:[String] = []
var uuidAudioArray:[String] = []
var uuidTextArray:[String] = []
var appBar = MDCAppBar()
    
    let memoHeaderView = GeneralHeaderView()
    
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
    var relations = Relations().relationArray.sorted()
     var passedSender:Any?
    var passedPerson: Recipient?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        print("Selected Person = \(passedPerson)")
        
        configureAppBar()
        title = "Add"
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        
        self.appBar.navigationBar.tintColor = .white
       
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//        
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        self.appBar.navigationBar.rightBarButtonItems = [self.contactItem]
        self.contactItem.tintColor = .red
        
        guard let theSent = passedSender else {
            print("You shall not pass!")
            return
        }
        print(theSent)
        
        
        form +++ Section()
            
            <<< TextRow(){ row in
                row.title = "Name Of Loved One"
                row.placeholder = "Enter a Name"
                row.tag = "lovedOneName"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                if passedSender is SelectionCollectionViewController {
                    row.value = passedPerson?.name
                }
                
            }
            <<< PickerInputRow<String>() { row in
                row.title = "Relation"
                row.options = relations
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.tag = "relation"
                if passedSender is SelectionCollectionViewController {
                    row.value = passedPerson?.relation
                }
                }.onChange({ (row) in
                    
                    guard let tree = self.form.rowBy(tag: "marriageDate") as? DateRow else {
                        return
                    }
                    if row.value == RelationEnum.Husband.rawValue || row.value == RelationEnum.Wife.rawValue{
                        //-TODO: Make Sure to unhide the row!!!!!
                        
                        tree.hidden = false
                        tree.evaluateHidden()
                        
                    } else{
                     tree.hidden = true
                        tree.evaluateHidden()
                    }
                })
            <<< DateRow() { row in
                row.title = "Birthday"
                row.value = Date(timeIntervalSinceReferenceDate: 0)
                row.tag = "birthdayDateTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is SelectionCollectionViewController {
                    row.value = passedPerson?.age as! Date
                }
                }.onChange({ (row) in
                    
                    guard let lovedOneEmail = self.form.rowBy(tag: "email") as? EmailRow else {
                        return
                    }
                    guard let rowValue = row.value else{
                        
                        print("The rowValue isn't present")
                        return
                    }
                    
                    guard let lovedOneNumber = self.form.rowBy(tag: "lovedOne#") as? PhoneRow else {
                        return
                    }
                    
                    
                    
                    let dateComponentsFormatter = DateComponentsFormatter()
                    let calendar = Calendar.current
                    
                    let date1 = calendar.startOfDay(for: Date())
                    let date2 = calendar.startOfDay(for: rowValue)
                    
                    let components = calendar.dateComponents([.year], from: date2, to: date1)
                    guard let age = components.year else {
                        return
                    }
                    
                    print(age)
                    
                    if age < 12 {
                        //-TODO: Make Sure to unhide the row!!!!!
                        
                        lovedOneEmail.hidden = true
                        lovedOneEmail.evaluateHidden()
                        lovedOneNumber.hidden = true
                        lovedOneNumber.evaluateHidden()
                        
                    } else{
                        lovedOneEmail.hidden = false
                        lovedOneEmail.evaluateHidden()
                        lovedOneNumber.hidden = false
                        lovedOneNumber.evaluateHidden()
                    }
                })
            
            
            <<< DateRow(){
                $0.title = "Marriage Date"
                $0.hidden = true
                $0.tag = "marriageDate"
                if $0.isHidden == false{
                     $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    if passedSender is SelectionCollectionViewController && passedPerson?.mariageDate != nil {
                        $0.value = passedPerson?.mariageDate as! Date
                    }
                }
                
               
            }
            
            <<< PhoneRow() {row in
                
                row.title = "Loved One #"
                row.placeholder = "916-111-2222"
                row.tag = "lovedOne#"
                if row.isHidden == false{
                    
                    row.add(rule: RuleRequired())
                    row.validationOptions = .validatesOnChange
                    if passedSender is SelectionCollectionViewController {
                        row.value = passedPerson?.phoneNumber
                    }
                }
            }
            <<< EmailRow(){ row in
                row.title = "Loved One's Email"
                row.placeholder = "email@gmail.com"
                row.tag = "email"
                if row.isHidden == false{
                    row.add(rule: RuleEmail())
                    row.add(rule: RuleRequired())
                    row.validationOptions = .validatesOnChange
                    if passedSender is SelectionCollectionViewController {
                        row.value = passedPerson?.email
                    }
                }
                
            }
            <<< TextRow(){ row in
                row.title = "Admin for loved one"
                row.placeholder = "Please input an admin for your loved one"
                row.tag = "adminTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is SelectionCollectionViewController {
                    row.value = passedPerson?.adminName
                }
            }
            
            <<< EmailRow(){ row in
                row.title = "Admin email"
                row.placeholder = "admin@gmail.com"
                row.tag = "adminEmailTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is SelectionCollectionViewController {
                    row.value = passedPerson?.adminEmail
                }
            }
            
            <<< ImageRow() { row in
                row.title = "Image of Loved One"
                row.tag = "lovedOnePicture"
                row.allowEditor = true
                row.useEditedImage = true
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is SelectionCollectionViewController {
                    row.value = UIImage(data: passedPerson?.avatar as! Data)
                }
            }
           
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                if passedSender is SelectionCollectionViewController {
                    row.title = "Update"
                }else {
                    row.title = "Save"
                    
                }
                
                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = UIColor(red: 0.102, green: 0.5569, blue: 0, alpha: 1.0)
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                   
                    
                    guard let nameRow: TextRow = self?.form.rowBy(tag: "lovedOneName") else {
                        return}
                    guard let nameRowValue = nameRow.value else {
                        self?.alertFunction(titleText: "Missing Value", bodyText: "You did not insert a name.")
                        return}
                    
                    guard let relationRow: PickerInputRow<String> = self?.form.rowBy(tag: "relation") else {return}
                    
                    guard let relationRowValue = relationRow.value else {
                        self?.alertFunction(titleText: "Missing Value", bodyText: "You must set a relation.")
                        return}
                    
                    guard let avatarRow: ImageRow = self?.form.rowBy(tag: "lovedOnePicture") else {return}
                    
                    guard let avatarRowValue = avatarRow.value else {
                        
                        let uploadAlert = UIAlertController(title: "Input Error", message: "Did you forget to set an image?", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                        
                        return}
                    
                    guard let birthdayRow: DateRow = self?.form.rowBy(tag: "birthdayDateTag") else {return}
                    
                    guard let birthDayRowValue = birthdayRow.value else {
                        self?.alertFunction(titleText: "Missing Value.", bodyText: "A birthday must be entered.")
                        return}
                    
                    guard let emailRow: EmailRow = self?.form.rowBy(tag: "email") else {return}
                    
                    var lovedOneEmail:String?
                    
                    if emailRow.isHidden {
                        lovedOneEmail = "none@none.none"
                    } else {
                        guard let emailRowValue = emailRow.value else {
                            self?.alertFunction(titleText: "Missing Value", bodyText: "You must enter an email address for your loved one.")
                            return}
                        
                        lovedOneEmail = emailRowValue
                    }
                    
                    
                    
                    /////
                    guard let numberRow: PhoneRow = self?.form.rowBy(tag: "lovedOne#") as? PhoneRow else {return}
                    
                    var lovedOneNumber:String?
                    
                    if numberRow.isHidden {
                        lovedOneNumber = "000-000"
                    } else {
                        guard let numberRowValue = numberRow.value else {
                            self?.alertFunction(titleText: "Missing Value", bodyText: "You must enter a phone number for your loved one.")
                            return}
                        
                        lovedOneNumber = numberRowValue
                    }
                    
                    
                    ////
                    
                    guard let adminNameRow: TextRow = self?.form.rowBy(tag: "adminTag") else {
                        return
                    }
                    guard let adminNameValue = adminNameRow.value else {
                        self?.alertFunction(titleText: "Missing Value", bodyText: "You must input a name for the admin.")
                        return
                    }
                    
                    guard let adminEmailRow: EmailRow = self?.form.rowBy(tag: "adminEmailTag") else {return}
                    
                    guard let adminEmailValue = adminNameRow.value else {
                        self?.alertFunction(titleText: "Missing Value", bodyText: "You must input an email for the admin.")
                        return}
                    
                    guard let marriageDateRow: DateRow = self?.form.rowBy(tag: "marriageDate") else {return}
                    
                    let marriageValue = marriageDateRow.value ?? Date()
                     
                    var lovedOneMarried: Bool = false
                    
                    if marriageDateRow.isHidden == true {
                        lovedOneMarried = false
                    } else if marriageDateRow.isHidden == false {
                        lovedOneMarried = true
                    }
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        //save function
                        // - MARK: If the user is not married then the date will show up the current day's date (date when saved) when we check later we can use the is married bool.
                        //TODO: Make sure to change the viewController that is checked!
                        if self?.passedSender is SelectionCollectionViewController {
                        
                            self?.update(recipientName: nameRowValue, avatar: avatarRowValue, birthday: birthDayRowValue, email: lovedOneEmail ?? "none@none.none", relation: relationRowValue, isMarried: lovedOneMarried, marriageDate: marriageValue, adminName: adminNameValue, adminEmail: adminEmailValue, lovedOneNumber:  lovedOneNumber ?? "916-000-000")
                            
                        } else {
                            self?.save(recipientName: nameRowValue, avatar: avatarRowValue, birthday: birthDayRowValue, email: lovedOneEmail ?? "none@none.none", relation: relationRowValue, isMarried: lovedOneMarried, marriageDate: marriageValue, adminName: adminNameValue, adminEmail: adminEmailValue, lovedOneNumber: lovedOneNumber ?? "916-000-000")
                        }
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }

        // Do any additional setup after loading the view.
    }


    }
    
    
    func update(recipientName: String, avatar: UIImage, birthday: Date, email: String, relation: String, isMarried: Bool, marriageDate: Date, adminName: String, adminEmail: String, lovedOneNumber: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
   //   let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let managedContext = passedPerson?.managedObjectContext else {return}
        do {
//            let person = Recipient(context: managedContext)
            guard let savedImageData = avatar.jpegData(compressionQuality: 0.80) as NSData? else {return}
            
            let personAudioMemos = passedPerson?.voice
            let personVideoMemos = passedPerson?.videos
            let persontextMemos = passedPerson?.written
            
            if let audioMemos = personAudioMemos {
                
                for memo in audioMemos {
                    
                    guard let audio = memo as? VoiceMemos, let uuid = audio.uuID else {
                        continue
                    }
                    uuidAudioArray.append(uuid)
                    
                }
            }
            
            if let videoMemos = personVideoMemos {
                
                for memo in videoMemos {
                    
                    guard let video = memo as? Videos, let uuid = video.uuID else {
                        continue
                    }
                    
                    uuidVideoArray.append(uuid)
                }
            }
            
            if let audioMemos = personAudioMemos {
                
                for memo in audioMemos {
                    
                    guard let audio = memo as? VoiceMemos, let uuid = audio.uuID else {
                        continue
                    }
                    
                    uuidTextArray.append(uuid)
                }
            }

            passedPerson?.name = recipientName
            passedPerson?.avatar = savedImageData
            passedPerson?.age = birthday as NSDate
            passedPerson?.email = email
            passedPerson?.relation = relation
            passedPerson?.married = isMarried
            passedPerson?.adminName = adminName
            passedPerson?.adminEmail = adminEmail
            if isMarried {
                passedPerson?.mariageDate = marriageDate as NSDate
                
            }
            
            
                try managedContext.save()
                print(" I saved")
                self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                
            
            
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        for uuid in uuidAudioArray {
            let dataBasePath = Database.database().reference().child("audioMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: uuid)
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {
                        continue
                    }
                    let editAtPath = Database.database().reference().child("audioMemos").child(userID).child(key)
                    print("___________")
                    print(key)
                    print("____________")
                    
                    editAtPath.updateChildValues(["lovedOne": recipientName, "lovedOneEmail": email, "relation": relation,"adminName": adminName, "adminEmail": adminEmail], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }
                    })
                }
                
                
                //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                
            }
        }
        
        for uuid in uuidVideoArray {
            let dataBasePath = Database.database().reference().child("videos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: uuid)
            dataBasePath.observeSingleEvent(of:.value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {
                        continue
                    }
                    
                    let editAtPath = Database.database().reference().child("videos").child(userID).child(key)
                    //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                    
                    editAtPath.updateChildValues(["lovedOne": recipientName, "lovedOneEmail": email, "relation": relation,"adminName": adminName, "adminEmail": adminEmail], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }
                    })
                    
                }
                
            }
        }
        
        for uuid in uuidTextArray {
            let dataBasePath = Database.database().reference().child("writtenMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: uuid)
            dataBasePath.observeSingleEvent(of:.value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {
                        continue
                    }
                    
                    let editAtPath = Database.database().reference().child("writtenMemos").child(userID).child(key)
                    //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                    
                    editAtPath.updateChildValues(["lovedOne": recipientName, "lovedOneEmail": email, "relation": relation,"adminName": adminName, "adminEmail": adminEmail], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }
                    })
                    
                }
                
            }
        }
        
        
    }
    

    func save(recipientName: String, avatar: UIImage, birthday: Date, email: String, relation: String, isMarried: Bool, marriageDate: Date, adminName: String, adminEmail: String, lovedOneNumber:String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
      
       
        
        do {
            
            
                
            let person = Recipient(context: managedContext)
                
                guard let savedImageData = avatar.jpegData(compressionQuality: 0.20) as NSData? else {return}
            
//            print(savedImageData.description)
                
            
//                person.setValue(recipientName, forKey: "name")
//                person.setValue(savedImageData, forKey: "avatar")
//                person.setValue(birthday, forKey: "age")
                person.name = recipientName
                person.avatar = savedImageData
                person.age = birthday as NSDate
                person.email = email
                person.relation = relation
                person.married = isMarried
                person.adminName = adminName
                person.adminEmail = adminEmail
                person.phoneNumber = lovedOneNumber
            if isMarried {
                person.mariageDate = marriageDate as NSDate
                
            }
            person.latestMemoDate = NSDate()

                do {
                    try managedContext.save()
                    print(" I saved")
                    
                    guard let userID = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    
                    Database.database().reference().child("users").child(userID).child(recipientName).observeSingleEvent(of: .value) { (snapshot) in
                        if snapshot.exists() {
                            //TODO: show a dialouge and make the user add on to the name some how
                            let editNameAlert = UIAlertController()
                            editNameAlert.title = "Error"
                            editNameAlert.message = "This person already exists. If this is a dfferent person with the same name add a modofer such as I or Jr."
                            
                            var textAction = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                                guard let textField = editNameAlert.textFields?[0].text else {return}
                                
                                if textField.isEmpty {
                                    self.alertFunction(titleText: "Error", bodyText: "You can't leave this empty")
                                } else {
                                
                                self.uploadMedia(avatar: avatar, name: recipientName, userID: userID, completion: { (url) in
                                    guard let url = url else {return}
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: birthday)
                                    let marDateString = dateFormat.string(from: marriageDate)
                                    
                                    Database.database().reference().child("users").child(userID).child("lovedOnes").child(recipientName).child("info").updateChildValues(["name" : textField,"avatar": url,"birthday": dateString,"email": email, "relation": relation,"married": isMarried, "admin": adminName, "adminEmail": adminEmail,"phoneNumber": lovedOneNumber, "marriageDate":marDateString])
                                })
                            }

                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            
                            editNameAlert.addTextField(configurationHandler: { (textAction) in
                                textAction.placeholder = "Enter a name"
                            })
                            
                            
                            editNameAlert.addAction(textAction)
                            editNameAlert.addAction(cancelAction)
                            
                            self.present(editNameAlert, animated: true, completion: nil)
                        } else {
                           
                            self.uploadMedia(avatar: avatar, name: recipientName, userID: userID, completion: { (url) in
                                guard let url = url else {return}
                                let dateFormat = DateFormatter()
                                dateFormat.dateFormat = "MM-dd-yyyy"
                                let dateString = dateFormat.string(from: birthday)
                                let marDateString = dateFormat.string(from: marriageDate)
                                
                                Database.database().reference().child("users").child(userID).child("lovedOnes").child(recipientName).child("info").updateChildValues(["name" : recipientName,"avatar": url,"birthday": dateString,"email": email, "relation": relation,"married": isMarried, "admin": adminName, "adminEmail": adminEmail,"phoneNumber": lovedOneNumber, "marriageDate":marDateString])
                            })
                            

                        }
                    }
                    

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



