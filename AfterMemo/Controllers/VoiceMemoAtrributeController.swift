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
    var passedSender:Any?
    
    var appBar = MDCAppBar()
    let memoHeaderView = MemoHeaderView()
    
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
    
    @objc func dismissME(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func findFutureDate( birthday: NSDate, targetAge: Int, mileStone: MileStones) -> Date {
        
        //We need to grab the birthday
        //then we need to add the target age to the birthday to get the future date
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "M-d-yyyy"
        
        let myString = formatter.string(from: birthday as Date) // string
        
        let ageComponents = myString.components(separatedBy: "-") //["1986", "06", "28"]
        
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
    @IBOutlet weak var progressView: CircularLoaderView!
    
    
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
    progressView.translatesAutoresizingMaskIntoConstraints = false
        form +++ Section("When will you send this memo?")
           
            <<< PickerInputRow<String>(){ row in
                row.title = "Mile Stone"
                row.options = triggers.triggerArray
                row.value = "None"
                row.tag = "audioTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is MemoListViewTableViewCell{
                    guard let audToEdit = sentVoiceMemo else{
                        return
                    }
                    row.value = audToEdit.mileStone
                }
                }.cellUpdate({ (cell, row) in
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
                        releaseDateRow.value = self.findFutureDate(birthday: birthday , targetAge: 30, mileStone: MileStones.AdditionalChildren)
                        
                        estimatedAgeRow.value = 30
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.BecomeGrandParent.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 50, mileStone: MileStones.BecomeGrandParent)
                        
                        estimatedAgeRow.value = 50
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.BuyingACar.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: MileStones.BuyingACar)
                        
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.CareerChange.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 24, mileStone: MileStones.CareerChange)
                        
                        estimatedAgeRow.value = 24
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FiftyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 50, mileStone: MileStones.FiftyBday)
                        estimatedAgeRow.value = 50
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstCareerJob.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 20, mileStone: MileStones.FirstCareerJob)
                        estimatedAgeRow.value = 20
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstChild.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 27, mileStone: MileStones.FirstChild)
                        estimatedAgeRow.value = 27
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FirstHome.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 32, mileStone: MileStones.FirstHome)
                        estimatedAgeRow.value = 32
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FiveYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 32, mileStone: MileStones.FiveYearWeddingAni)
                        estimatedAgeRow.value = 32
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.FourtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 40, mileStone: MileStones.FourtyBday)
                        estimatedAgeRow.value = 40
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.GraduatingCollege.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: MileStones.GraduatingCollege)
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.GraduatingHighSchool.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 17, mileStone: MileStones.GraduatingHighSchool)
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
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 26, mileStone: MileStones.Marriage)
                        estimatedAgeRow.value = 26
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.PassDrivingTest.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 16, mileStone: MileStones.PassDrivingTest)
                        estimatedAgeRow.value = 16
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SecondChild.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 30, mileStone: MileStones.SecondChild)
                        estimatedAgeRow.value = 30
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SeventyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 70, mileStone: MileStones.SeventyBday)
                        estimatedAgeRow.value = 70
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SevenYearSlump.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 34, mileStone: MileStones.SevenYearSlump)
                        estimatedAgeRow.value = 34
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.SixtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 60, mileStone: MileStones.SixtyBday)
                        estimatedAgeRow.value = 60
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TenYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 37, mileStone: MileStones.TenYearWeddingAni)
                        estimatedAgeRow.value = 37
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.ThirtyBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 30, mileStone: MileStones.ThirtyBday)
                        estimatedAgeRow.value = 30
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TwentyFirstBday.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 21, mileStone: MileStones.TwentyFirstBday)
                        estimatedAgeRow.value = 21
                        estimatedAgeRow.reload()
                        releaseDateRow.reload()
                        
                    case MileStones.TwentyYearWeddingAni.rawValue:
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 47, mileStone: MileStones.TwentyYearWeddingAni)
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
                    default:
                        print("No")
                    }
                    
                    
                })
            <<< IntRow() {row in
                row.title = "Approximate Age At Release"
                row.tag = "estimatedAge"
                
                
                if passedSender is MemoListViewTableViewCell{
                    guard let audToEdit = sentVoiceMemo else{
                        return
                    }
                    let dateToEdit = sentVoiceMemo?.dateToBeReleased
                    
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
                    
                    //row.value = String(estimadeAgeYear)
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
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.tag = "dateTag"
                
                if passedSender is MemoListViewTableViewCell {
                    
                    guard let dateToEdit = sentVoiceMemo?.dateToBeReleased else {
                        return
                    }
                    
                    row.value = dateToEdit as Date
                }
                
                
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
                
                if passedSender is MemoListViewTableViewCell {
                    
                    guard let dateToEdit = sentVoiceMemo?.releaseTime else {
                        return
                    }
                    
                    row.value = dateToEdit as Date
                }
                
                }  .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.backgroundColor = UIColor.red
                    }
                })
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                guard let theSender = passedSender  else {
                    print("could not set")
                    return
                }
                
                if theSender is MemoListViewTableViewCell{
                    row.title = "Set Attributes"
                    
                } else {
                    row.title = "Create Voice Memo"
                    print("THE SENDER: \(theSender)")
                    
                }

                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = UIColor(red: 0.102, green: 0.5569, blue: 0, alpha: 1.0)
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        guard let theSender = self?.passedSender  else {
                            print("could not set")
                            return
                        }
                        
                        if theSender is MemoListViewTableViewCell {
                            
                            guard let audioTagRow: PickerInputRow<String> = self?.form.rowBy(tag: "audioTag") else {
                                print("fail 1")
                                return}
                            guard let audioTagRowValue = audioTagRow.value else {
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
                            
                            
                            self?.updateDataBase(audioTag:audioTagRowValue , releaseDate: dateRowValue, releaseTime: timeRowValue)
                            
                        } else {
                            self?.performSegue(withIdentifier: "voiceAttributes", sender: self)
                        }
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
}
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceAttributes" {
            
            guard let destinationVC = segue.destination as? RecordingViewController else {return}
            
            guard let auidoTagRow: PickerInputRow<String> = self.form.rowBy(tag: "audioTag") else {return}
            guard let audioTagRowValue = auidoTagRow.value else {return}
            guard let dateRow: DateRow = self.form.rowBy(tag: "dateTag") else {
                return
            }
            guard let dateRowValue = dateRow.value else {return}
            
            guard let timeRow: TimeRow = self.form.rowBy(tag: "timeTag") else {return}
            guard let timeRowValue = timeRow.value else {return}
            guard let lovedOneName = selectedPerson?.name else {return}
            guard let lovedOneEmail = selectedPerson?.email else {return}
            
            destinationVC.selectedPerson = selectedPerson
            //destinationVC.audioStorageURL = ""
            destinationVC.audioTag = audioTagRowValue
            destinationVC.releaseDate = dateRowValue
            destinationVC.releaseTime = timeRowValue
            destinationVC.lovedOne = lovedOneName
            destinationVC.uuID = uuid
           // destinationVC.audioOnDeviceURL = ""
            destinationVC.createdDate = Date()
            destinationVC.lovedOneEmail = lovedOneEmail
            destinationVC.passedSender = sender
            
        }
    }
    
    func updateDataBase(audioTag:String, releaseDate: Date, releaseTime:Date){
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let checkingValue = sentVoiceMemo?.uuID else {
            print("THe passed video can't be unwrapped")
            return
        }
        
        sentVoiceMemo?.creationDate = NSDate()
        sentVoiceMemo?.mileStone = audioTag
        sentVoiceMemo?.dateToBeReleased = releaseDate as NSDate
        sentVoiceMemo?.releaseTime = releaseTime as NSDate
        
        do {
            try  sentVoiceMemo?.managedObjectContext?.save()
            
            guard let creationDate =  sentVoiceMemo?.creationDate as Date? else {return}
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "M-d-yyyy"
            let dateString = dateFormat.string(from: releaseDate)
            
            let createdDateString = dateFormat.string(from: creationDate)
            
            let timeFormat = DateFormatter()
            
            timeFormat.dateFormat = "h:mm a"
            
            let timeString = timeFormat.string(from: releaseTime)
            
            let dataBasePath = Database.database().reference().child("audioMemos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: checkingValue)
            
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {continue}
                    //TODO: NEED TO MAKE THIS CHANGE TO ALL UPDATES ^^^^
                    
                    let editAtPath = Database.database().reference().child("audioMemos").child(userID).child(key)
                    //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                    
                    editAtPath.updateChildValues(["audioTag": audioTag, "releaseDate": dateString, "releaseTime": timeString], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }else {
                            
                            let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                            
                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                self.performSegue(withIdentifier: "done", sender: self)
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
    
    func save(audioTag: String, releaseDate: Date, releaseTime: Date, passedURL: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        guard let currentaudio = sentVoiceMemo else {
            print("The voice memo did not pass")
            return}
        
              
                currentaudio.mileStone = audioTag
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
                                    dateFormat.dateFormat = "M-d-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    let createdDateString = dateFormat.string(from: creationDate)
                                    
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                    
                                    guard let lovedOneName = self.selectedPerson?.name else {return}
                                    guard let lovedOneEmail = self.selectedPerson?.email else {return}
                                    guard let adminName = self.selectedPerson?.adminName else {return}
                                    guard let adminEmail = self.selectedPerson?.adminEmail else {return}
                                    
                                    dataBasePath.updateChildValues(["audioStorageURL": auidoURLString,"audioTag": audioTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": self.uuid, "audioOnDeviceURL": audioURL,"createdDate": createdDateString, "lovedOneEmail": lovedOneEmail, "adminName": adminName, "adminEmail": adminEmail], withCompletionBlock: { (error, ref) in
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
