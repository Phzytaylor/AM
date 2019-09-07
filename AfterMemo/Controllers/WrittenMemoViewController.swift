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
    let memoHeaderView = MemoHeaderView()
    var passedSender:Any?
    
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
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    func alertFunction(titleText:String, bodyText:String){
        let alertView = UIAlertController(title: titleText, message: bodyText, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    @objc func dismissME(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var loadingView: CircularLoaderView!
    let uuid = UUID().uuidString
    
    var selectedPerson: Recipient?
    
    var triggers = Triggers()
    
    var passedMemo: Written?
    
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    func findFutureDate( birthday: NSDate, targetAge: Int, mileStone: MileStones) -> Date {
        
        //We need to grab the birthday
        //then we need to add the target age to the birthday to get the future date
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "M-d-yyyy"
        
        let myString = formatter.string(from: birthday as Date) // string
        
        print("MY STRING:\(myString)")
        
        let ageComponents = myString.components(separatedBy: "-") //["1986", "06", "28"]
        
        print(ageComponents)
        
        let dateDOB = Calendar.current.date(from: DateComponents(year:
            Int(ageComponents[2]), month: Int(ageComponents[0]), day:
            Int(ageComponents[1])))!
        
        
        let myAge = dateDOB.age
        
        print(myAge)
        
        
        var dateComponent = DateComponents()
        
        let diff = targetAge - myAge
        
        // dateComponent.year = targetAge - myAge
        
        let releaseYear = Calendar.current.date(byAdding: .year, value: diff, to: Date())
        
        let calender = Calendar(identifier: .gregorian)
        
        dateComponent.year = calender.component(.year, from: releaseYear ?? Date())
        
        //TODO: Will want to grab the wedding date of the user and change the month to match just as I have done for graduations.
        switch mileStone {
        case .GraduatingCollege , .GraduatingHighSchool:
            dateComponent.month = 6
            let date = calender.date(from: dateComponent)
            
            return date ?? Date()
            
        case .Birthday:
            dateComponent.year = Calendar.current.component(.year, from: Date())
            
            let date = calender.date(from: dateComponent)
            
            return date ?? Date()
            
        default:
            let date = calender.date(from: dateComponent)
            return date ?? Date()
        }
        
        //        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date()) else {
        //            return Date()
        //        }
        
        // return futureDate
    }
    
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true 
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        configureAppBar()
        appBar.navigationBar.tintColor = .white
        
        memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        memoHeaderView.imageViewCenterCon?.isActive = true
        
        memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: memoHeaderView.centerYAnchor, constant: -30.0)
        
        memoHeaderView.imageViewYCon?.isActive = true
        
        memoHeaderView.imageView.layoutIfNeeded()
        
        if passedSender is OptionsViewController {
            self.appBar.navigationBar.backItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(dismissME))
        }
        
        if passedSender is SelectionCollectionViewController {
            
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            
        }


        form +++ Section("Write a Memo for a loved one")
            <<< TextAreaRow(){row in
                row.title = "Write A Memo"
                row.placeholder = "Think of a future event such as a graduation, tell them how much you love them and how proud you are."
                row.tag = "memoText"
              
                if passedSender is MemoListViewTableViewCell {
                    if let rowValue = passedMemo?.memoText {
                        row.value = rowValue
                    }
                }
        }
        
       +++ Section("When will you send this memo?")
            <<< PickerInputRow<String>(){ row in
                row.title = "Mile Stone"
                row.options = triggers.triggerArray
                row.value = "None"
                row.tag = "memoTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                
                if passedSender is MemoListViewTableViewCell{
                    guard let textToEdit = passedMemo else{
                        return
                    }
                    row.value = textToEdit.mileStone
                }
                
                }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                }).onChange({ (row) in
                    let releaseDateRow = self.form.rowBy(tag: "dateTag") as! DateRow
                    
                    guard let currentValue = row.value else {
                        
                        print("No Value")
                        return
                    }
                    
                    let estimatedAgeRow = self.form.rowBy(tag: "estimatedAge") as! IntRow
                    
                    
                    guard let currentPerson = self.selectedPerson else {
                        print("Could not grab person")
                        return}
                    
                    guard let birthday = currentPerson.age else {
                        
                        print("Could not grab age")
                        return}
                    switch currentValue {
                    case MileStones.AdditionalChildren.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday , targetAge: 30, mileStone: .AdditionalChildren)
                        
                        estimatedAgeRow.value = 30
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.BecomeGrandParent.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 50, mileStone: .BecomeGrandParent)
                        
                        estimatedAgeRow.value = 50
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.BuyingACar.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: .BuyingACar)
                        
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.CareerChange.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 24, mileStone: .CareerChange)
                        
                        estimatedAgeRow.value = 24
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FiftyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 50, mileStone: .FiftyBday)
                        estimatedAgeRow.value = 50
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstCareerJob.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 20, mileStone: .FirstCareerJob)
                        estimatedAgeRow.value = 20
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstChild.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 25, mileStone: .FirstChild)
                        estimatedAgeRow.value = 25
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstHome.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 32, mileStone: .FirstHome)
                        estimatedAgeRow.value = 32
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FiveYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 32, mileStone: .FiveYearWeddingAni)
                        estimatedAgeRow.value = 32
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FourtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 40, mileStone: .FourtyBday)
                        estimatedAgeRow.value = 40
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.GraduatingCollege.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: .GraduatingCollege)
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.GraduatingHighSchool.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 17, mileStone: .GraduatingHighSchool)
                        estimatedAgeRow.value = 17
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.MidlifeEncourgement.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 43, mileStone: .MidlifeEncourgement)
                        estimatedAgeRow.value = 43
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                    case MileStones.LossOfLovedOne.rawValue:
                        print("No change age must be set")
                    case MileStones.Marriage.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 27, mileStone: .Marriage)
                        estimatedAgeRow.value = 27
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.PassDrivingTest.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 16, mileStone: .PassDrivingTest)
                        estimatedAgeRow.value = 16
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SecondChild.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 27, mileStone: .SecondChild)
                        estimatedAgeRow.value = 27
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SeventyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 70, mileStone: .SeventyBday)
                        estimatedAgeRow.value = 70
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SevenYearSlump.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 34, mileStone: .SevenYearSlump)
                        estimatedAgeRow.value = 34
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SixtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 60, mileStone: .SixtyBday)
                        estimatedAgeRow.value = 60
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TenYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 37, mileStone: .TenYearWeddingAni)
                        estimatedAgeRow.value = 37
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.ThirtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 30, mileStone: .ThirtyBday)
                        estimatedAgeRow.value = 30
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TwentyFirstBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: .TwentyFirstBday)
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TwentyYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 47, mileStone: .TwentyYearWeddingAni)
                        estimatedAgeRow.value = 47
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.Birthday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 0, mileStone: .Birthday)
                        
                        guard let bday = self.selectedPerson?.age else {
                            return
                        }
                        
                        let estAge = Date().years(from:bday as Date)
                        
                        let absAge = abs(estAge)
                        
                        estimatedAgeRow.value = absAge
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                        //
                    default:
                        print("No")
                    }
                    
                    
                })
            <<< IntRow() {row in
                row.title = "Approximate Age At Release"
                row.tag = "estimatedAge"
                
                if passedSender is MemoListViewTableViewCell{
                    guard let textToEdit = passedMemo else{
                        return
                    }
                    let dateToEdit = passedMemo?.dateToBeReleased
                    
                    guard let currentPerson = self.selectedPerson else {
                        print("Could not grab person")
                        return}
                    
                    guard let birthday = currentPerson.age else {
                        
                        print("Could not grab age")
                        return}
                    
                    let userCalendar = Calendar.current
                    
                    let estimatedAge = userCalendar.dateComponents([.year], from:birthday as! Date , to:dateToEdit as! Date)
                    
                    guard let estimadeAgeYear = estimatedAge.year else {
                        return
                    }
                    
                    row.value = estimadeAgeYear
                    
                    
                    
                }
                
                }.onChange({ (row) in
                    let releaseDateRow = self.form.rowBy(tag: "dateTag") as! DateRow
                    
                   
                    guard let rowVal = row.value else {
                        return
                    }
                    
                    
                    guard let currentPerson = self.selectedPerson else {
                        print("Could not grab person")
                        return}
                    
                    guard let birthday = currentPerson.age else {
                        
                        print("Could not grab age")
                        return}
                    
                    let targetedAge = rowVal
                    
                    releaseDateRow.value = self.findFutureDate(birthday: birthday , targetAge: targetedAge, mileStone: .None)
                    
                    releaseDateRow.reload()
                    
                })
            <<< DateRow() { row in
                row.title = "Date To Be Released"
                row.value = Date()
                row.tag = "dateTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                if passedSender is MemoListViewTableViewCell {
                    
                    guard let dateToEdit = passedMemo?.dateToBeReleased else {
                        return
                    }
                    
                    row.value = dateToEdit as Date
                }
                
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
                
                if passedSender is MemoListViewTableViewCell {
                    
                    guard let dateToEdit = passedMemo?.releaseTime else {
                        return
                    }
                    
                    row.value = dateToEdit as Date
                }
                
                }                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.backgroundColor = UIColor.red
                    }
                })
            //TODO: Replace this button row with a button in a header or footer instead. Use the sign up as an example
        
            +++ Section(){ section in
                var header = HeaderFooterView<UIView>(.class) // most flexible way to set up a header using any view type
                header.height = { 50 }  // height can be calculated
                let button = MDCButton()
                
                
                header.onSetupView = { view, section in  // each time the view is about to be displayed onSetupView is invoked.
                    //view.backgroundColor = .orange
                    
                    
                    view.addSubview(button)
                    button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30.0).isActive = true
                    button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30.0).isActive = true
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.setTitle("Reset Password", for: .normal)
                    button.backgroundColor = .black
                    button.addTarget(self, action: #selector(self.submitAction), for: .touchUpInside)
                }
                section.header = header
        }
        
        
//            <<< ButtonRow() { (row: ButtonRow) -> Void in
//                row.title = "Save"
//
//                }
//                .cellSetup() {cell, row in
//                    cell.backgroundColor = UIColor(red: 0.102, green: 0.5569, blue: 0, alpha: 1.0)
//                    cell.tintColor = .white
//                }
//                .onCellSelection { [weak self] (cell, row) in
//
//
//        }
        
        // Do any additional setup after loading the view.
    }
    
   @objc func submitAction(){
        //TODO: Move implementation from the button row to here.
        guard let memoTagRow: PickerInputRow<String> = self.form.rowBy(tag: "memoTag") else {return}
        guard let memoTagRowValue = memoTagRow.value else {
            self.alertFunction(titleText: "Empty Field", bodyText: "You must select a mile stone for the memo.")
            return}
        guard let dateRow: DateRow = self.form.rowBy(tag: "dateTag") else {
            return
        }
        guard let dateRowValue = dateRow.value else {
            self.alertFunction(titleText: "Empty Field", bodyText: "You must set a minimum release date.")
            return}
        
        guard let timeRow: TimeRow = self.form.rowBy(tag: "timeTag") else {return}
        guard let timeRowValue = timeRow.value else {
            self.alertFunction(titleText: "Empty Field", bodyText: "You must set a minimum release time.")
            return}
        
        guard let memoTextRow: TextAreaRow = self.form.rowBy(tag: "memoText") else {return}
        
        guard let memoTexRowValue = memoTextRow.value else {
            self.alertFunction(titleText: "Empty Field", bodyText: "You must enter a message.")
            return}
        
        
        
        
        if !form.validate().isEmpty{
            
            //save function
            
            if self.passedSender is MemoListViewTableViewCell {
                // write updateFunction
                self.updateDataBase(memoTag:memoTagRowValue , releaseDate: dateRowValue, releaseTime: timeRowValue, memoText: memoTexRowValue)
                
            } else {
                self.save(memoTag: memoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, memoText: memoTexRowValue)
            }
            
            
            
        }
            
        else {
            let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
            uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(uploadAlert, animated: true, completion: nil)
        }
    }
    
    func updateDataBase(memoTag: String, releaseDate: Date, releaseTime: Date, memoText: String){
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let checkingValue = passedMemo?.uuID else {
            print("THe passed video can't be unwrapped")
            return
        }
        
        passedMemo?.creationDate = NSDate()
        passedMemo?.mileStone = memoTag
        passedMemo?.dateToBeReleased = releaseDate as NSDate
        passedMemo?.releaseTime = releaseTime as NSDate
        
        do {
            try  passedMemo?.managedObjectContext?.save()
            
            guard let creationDate =  passedMemo?.creationDate as Date? else {return}
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "M-d-yyyy"
            let dateString = dateFormat.string(from: releaseDate)
            
            let createdDateString = dateFormat.string(from: creationDate)
            
            let timeFormat = DateFormatter()
            
            timeFormat.dateFormat = "h:mm a"
            
            let timeString = timeFormat.string(from: releaseTime)
            
            let dataBasePath = Database.database().reference().child("writtenMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: checkingValue)
            
            dataBasePath.observeSingleEvent(of:.value) { (snapshot) in
                
                for child in snapshot.children {
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {
                        continue
                    }
                    
                    let editAtPath = Database.database().reference().child("writtenMemos").child(userID).child(key)
                    //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                    
                    editAtPath.updateChildValues(["memoTag": memoTag, "releaseDate": dateString, "releaseTime": timeString,"memoText": memoText], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }else {
                            
                            let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                            
                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                self.performSegue(withIdentifier: "fromWritten", sender: self)
                            }))
                            
                            self.present(successAlert, animated: true, completion: nil)
                            
                            
                        }
                    })
                }
                
               
            }
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
        
        written.mileStone = memoTag
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
                    dateFormat.dateFormat = "M-d-yyyy"
                    let dateString = dateFormat.string(from: releaseDate)
                    let createdDateString = dateFormat.string(from: creationDate)
                    
                    let timeFormat = DateFormatter()
                    
                    timeFormat.dateFormat = "h:mm a"
                    
                    let timeString = timeFormat.string(from: releaseTime)
                    
                    guard let lovedOneName = selectedPerson?.name else {return}
                    guard let lovedOneEmail = selectedPerson?.email else {return}
                    guard let lovedOneRelation = selectedPerson?.relation else {return}
                    guard let adminName = selectedPerson?.adminName else {return}
                    guard let adminEmail = selectedPerson?.adminEmail else {return}
                    
                    //"timestamp": ["sv": "timestamp"]
                    
                    dataBasePath.updateChildValues(["memoTag": memoTag, "releaseDate": dateString, "releaseTime": timeString, "memoText": memoText, "lovedOne" : lovedOneName, "uuID": uuid,"createdDate": createdDateString, "lovedOneEmail": lovedOneEmail, "relation": lovedOneRelation, "adminName": adminName, "adminEmail": adminEmail]) { (error, ref) in
                        if error != nil {
                            print("Upload did not work")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }else{
                            
                            self.loadingView.progress = 1.0
                            if let memoKey = ref.key {
                                Database.database().reference().child("users").child(userID).child("lovedOnes").child(lovedOneName).child("memos").updateChildValues([memoKey : memoKey])
                                
                            }
                            
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
