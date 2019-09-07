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
import MaterialComponents
import AVFoundation
import AVKit
import MobileCoreServices
class VideoAtrributesViewController: FormViewController {
var appBar = MDCAppBar()
    let memoHeaderView = MemoHeaderView()
    var fileName = ""
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
    var passedVideoURL: String = ""
    var selectedPerson: Recipient?
    var passedVideo: Videos?
    var triggers = Triggers()
    var passedSender:Any?
    
    
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
    
    
    @objc func dismissME(){
        self.dismiss(animated: true, completion: nil)
    }
     //let uuid = UUID().uuidString
    @IBOutlet weak var progressReport: CircularLoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressReport.translatesAutoresizingMaskIntoConstraints = false
        
        configureAppBar()
        appBar.navigationBar.tintColor = .white
        
        memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        memoHeaderView.imageViewCenterCon?.isActive = true
        
        memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: memoHeaderView.centerYAnchor, constant: -30.0)
        
        memoHeaderView.imageViewYCon?.isActive = true
        
        memoHeaderView.imageView.layoutIfNeeded()
        
        if passedSender is SelectionCollectionViewController {
            
            navigationController?.setNavigationBarHidden(true, animated: false)
        
            
        }
        
        if passedSender is OptionsViewController {
            self.appBar.navigationBar.backItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(dismissME))
        }
        
       
        
        
        
//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        print("The sender was \(passedSender)")
        form +++ Section("When will you send this memo?")
            <<< PickerInputRow<String>(){ row in
                row.title = "Mile Stone"
               row.options = triggers.triggerArray.sorted()
                row.value = "None"
                row.tag = "videoTag"
                if passedSender is MemoListViewTableViewCell{
                    guard let vidToEdit = passedVideo else{
                        return
                    }
                    row.value = vidToEdit.mileStone
                    }
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
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
                        releaseDateRow.value = self.findFutureDate(birthday: birthday, targetAge: 32, mileStone: .FirstChild)
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
                        default:
                       print("No")
                    }
                    
                    
                })
            <<< IntRow() {row in
                row.title = "Approximate Age At Release"
                row.tag = "estimatedAge"
                
                if passedSender is MemoListViewTableViewCell{
                    guard let vidToEdit = passedVideo else{
                        return
                    }
                    let dateToEdit = passedVideo?.dateToBeReleased
                  
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
                    
                    guard let currentValue = row.value else {
                        
                        print("No Value")
                        return
                    }
                    
                    guard let rowVal = row.value else {
                        return
                    }
                    
                    let estimatedAgeRow = self.form.rowBy(tag: "estimatedAge") as! IntRow
                    
                    
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
            row.value = Date(timeIntervalSinceReferenceDate: 0)
            row.tag = "dateTag"
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            
            if passedSender is MemoListViewTableViewCell {
                
                guard let dateToEdit = passedVideo?.dateToBeReleased else {
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
                row.value = Date()
                row.tag = "timeTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                if passedSender is MemoListViewTableViewCell {
                    
                    guard let dateToEdit = passedVideo?.releaseTime else {
                        return
                    }
                    
                    row.value = dateToEdit as Date
                }
                
                }                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.backgroundColor = UIColor.red
                    }
                })

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                guard let theSender = passedSender  else {
                    print("could not set")
                    return
                }
                
                print(theSender)
                
             
                
                if theSender is MemoListViewTableViewCell{
                    row.title = "Save New Attributes"
                    
                } else {
                    row.title = "Record Video"
                    
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
                            
                            // need to make an update function
                            
//                            videoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, videoDataPath: dataPath
                            
                            guard let videoTagRow: PickerInputRow<String> = self?.form.rowBy(tag: "videoTag") else {
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
                            
                            
                            self?.updateDataBase(videoTag:videoTagRowValue , releaseDate: dateRowValue, releaseTime: timeRowValue)
                            
                        } else{
                            
                            VideoHelper.startMediaBrowser(delegate: self!, sourceType: .camera)
                            
                        }
                    
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must containe values in order to save", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
        }
        // Do any additional setup after loading the view.
    }
    
    func updateDataBase(videoTag:String, releaseDate: Date, releaseTime:Date){
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let checkingValue = passedVideo?.uuID else {
            print("THe passed video can't be unwrapped")
            return
        }
        
        passedVideo?.creationDate = NSDate()
        passedVideo?.mileStone = videoTag
        passedVideo?.dateToBeReleased = releaseDate as NSDate
        passedVideo?.releaseTime = releaseTime as NSDate
        
        do {
           try  passedVideo?.managedObjectContext?.save()
            
            guard let creationDate =  passedVideo?.creationDate as Date? else {return}
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "M-d-yyyy"
            let dateString = dateFormat.string(from: releaseDate)
            
            let createdDateString = dateFormat.string(from: creationDate)
            
            let timeFormat = DateFormatter()
            
            timeFormat.dateFormat = "h:mm a"
            
            let timeString = timeFormat.string(from: releaseTime)
            
            let dataBasePath = Database.database().reference().child("videos").child(userID).queryOrdered(byChild: "uuID").queryEqual(toValue: checkingValue)
            
            dataBasePath.observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    let snap = child as? DataSnapshot
                    guard let key = snap?.key else {
                        continue
                    }
                    
                    let editAtPath = Database.database().reference().child("videos").child(userID).child(key)
                    //  ["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString]
                    
                    editAtPath.updateChildValues(["videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to update Database")
                            
                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(databaseError, animated: true, completion: nil)
                            return
                        }else {
                            
                            let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                            
                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                self.performSegue(withIdentifier: "backtoMain", sender: self)
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
    
    func save(vidUrl:String, _ tempFilePath: URL, videoTag: String, releaseDate: Date, releaseTime: Date, videoDataPath: URL){
        
        // goal Save video and it's attributes
        
      
        
        guard let currentPerson = selectedPerson else {return}
        guard let currentContext = currentPerson.managedObjectContext else {return}
        
        let video = Videos(context: currentContext)
        
        guard let savedImage = previewImageForLocalVideo(url: tempFilePath) else {return}
       
        let savedImageData = savedImage.pngData() as NSData?
        let uuid = UUID().uuidString
    
        video.thumbNail = savedImageData
        video.urlPath = vidUrl
        video.isVideo = true
        video.isVoiceMemo = false
        video.isWrittenMemo = false
        video.uuID = uuid
        video.creationDate = NSDate()
        video.mileStone = videoTag
        video.dateToBeReleased = releaseDate as NSDate
        video.releaseTime = releaseTime as NSDate
        
        let uuID = video.uuID
        let lovedOneEmail = currentPerson.email

        if let videos = currentPerson.videos?.mutableCopy() as? NSMutableOrderedSet {
            videos.add(video)
            currentPerson.latestMemoDate = NSDate()
            currentPerson.addToVideos(videos)
        }
        
        do {
                try currentContext.save()
            print("I saved")
            guard let userID = Auth.auth().currentUser?.uid else {return}
            
            let uploadLink = Storage.storage().reference().child(userID).child("videos").child(vidUrl + videoTag)
            
            guard let videoURLForUpload = URL(string: videoDataPath.absoluteString) else {return}
            
            let uploadTask =  uploadLink.putFile(from: videoURLForUpload, metadata: nil) { (metadatas, error) in
                if error != nil {
                    print("This video could not load!")
                    return
                } else {
                    
                    uploadLink.downloadURL(completion: { (url, error) in
                        
                        if error != nil {
                            
                            print("Failure to grab url")
                            let uploadError = UIAlertController(title: "Error!", message: "The download url could not be grabbed", preferredStyle: .alert)
                            
                            uploadError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(uploadError, animated: true, completion: nil)
                            
                            return
                        } else {
                            let dataBasePath = Database.database().reference().child("videos").child(userID).childByAutoId()
                            
                            guard let videoURLString = url?.absoluteString else {return}
                            
                            guard let creationDate = video.creationDate as Date? else {return}
                            let dateFormat = DateFormatter()
                            dateFormat.dateFormat = "M-d-yyyy"
                            let dateString = dateFormat.string(from: releaseDate)
                            
                            let createdDateString = dateFormat.string(from: creationDate)
                            
                            let timeFormat = DateFormatter()
                            
                            timeFormat.dateFormat = "h:mm a"
                            
                            let timeString = timeFormat.string(from: releaseTime)
                            
                            guard let lovedOneName = self.selectedPerson?.name else {return}
                            guard let lovedOneRelation = self.selectedPerson?.relation else {return}
                            
                            guard let adminName = self.selectedPerson?.adminName else {return}
                            
                            guard let adminEmail = self.selectedPerson?.adminEmail else {return}
                            
                            dataBasePath.updateChildValues(["videoStorageURL": videoURLString,"videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": video.uuID, "videoOnDeviceURL": vidUrl, "createdDate": createdDateString, "lovedOneEmail": lovedOneEmail, "relation": lovedOneRelation, "adminName": adminName, "adminEmail": adminEmail], withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print("failed to update Database")
                                    
                                    let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                                    
                                    databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    self.present(databaseError, animated: true, completion: nil)
                                    return
                                }else {
                                    if let memoKey = ref.key {
                                        Database.database().reference().child("users").child(userID).child("lovedOnes").child(lovedOneName).child("memos").updateChildValues([memoKey : memoKey])
                                        
                                    }
                                    let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                                    
                                    successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                        self.performSegue(withIdentifier: "backtoMain", sender: self)
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
                
                self.progressReport.progress = CGFloat(percentComplete)
            }

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
   
    
    
    /*func saves(videoTag: String, releaseDate: Date, releaseTime: Date, passedURL: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
  
        guard let currentVideo = passedVideo else {
            
            print("Didn't pass")
            return}
                currentVideo.videoTag = videoTag
                currentVideo.dateToBeReleased = releaseDate as NSDate
                currentVideo.releaseTime = releaseTime as NSDate
                let uuID = currentVideo.uuID
        guard let lovedOneEmail = selectedPerson?.email else {
            return
        }
                
                
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
                    
                    
                    
                let uploadTask =  uploadLink.putFile(from: videoURLForUpload, metadata: nil) { (metadatas, error) in
                        if error != nil {
                            print("This video could not load!")
                            return
                        } else {
                            
                            uploadLink.downloadURL(completion: { (url, error) in
                                
                                if error != nil {
                                    
                                    print("Failure to grab url")
                                    let uploadError = UIAlertController(title: "Error!", message: "The download url could not be grabbed", preferredStyle: .alert)
                                    
                                    uploadError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    self.present(uploadError, animated: true, completion: nil)
                                    
                                    return
                                } else {
                                let dataBasePath = Database.database().reference().child("videos").child(userID).childByAutoId()
                                    
                                    guard let videoURLString = url?.absoluteString else {return}
                                    
                                    guard let creationDate = currentVideo.creationDate as Date? else {return}
                                    let dateFormat = DateFormatter()
                                    dateFormat.dateFormat = "EEEE, MM-dd-yyyy"
                                    let dateString = dateFormat.string(from: releaseDate)
                                    
                                    let createdDateString = dateFormat.string(from: creationDate)
                                    
                                    let timeFormat = DateFormatter()
                                    
                                    timeFormat.dateFormat = "h:mm a"
                                    
                                    let timeString = timeFormat.string(from: releaseTime)
                                    
                                    guard let lovedOneName = self.selectedPerson?.name else {return}
                                
                                    dataBasePath.updateChildValues(["videoStorageURL": videoURLString,"videoTag": videoTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": currentVideo.uuID, "videoOnDeviceURL":videoURL, "createdDate": createdDateString, "lovedOneEmail": lovedOneEmail], withCompletionBlock: { (error, ref) in
                                        if error != nil {
                                            print("failed to update Database")
                                            
                                            let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                                            
                                            databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                            
                                            self.present(databaseError, animated: true, completion: nil)
                                            return
                                        }else {
                                            
                                            let successAlert = UIAlertController(title: "Success", message: "Your video and it's attributes were uploaded successfully", preferredStyle: .alert)
                                            
                                            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
                                                self.performSegue(withIdentifier: "backtoMain", sender: self)
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
                        
                        self.progressReport.progress = CGFloat(percentComplete)
                    }
                    
                }
                catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
        
       
        
       
    }
    
    */
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VideoAtrributesViewController{
    
    func previewImageForLocalVideo(url:URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let tVal = NSValue(time: CMTimeMake(value: 12, timescale: 1)) as! CMTime
        do {
            let imageRef = try imageGenerator.copyCGImage(at: tVal, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
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


extension VideoAtrributesViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        dismiss(animated: true, completion: nil)
        
        let nameFileAlert = UIAlertController(title: "Save?", message: "Would you like to save your video?.", preferredStyle: .alert)
        
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (UIAlertAction) in
            
            
            
            guard
                let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
                else {
                    return
            }
            
//            let videoData = try? Data(contentsOf: url )
//            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//
//            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
//            let dataPath =
//                documentsDirectory.appendingPathComponent(self.fileName)
            
            
            guard let videoTagRow: PickerInputRow<String> = self.form.rowBy(tag: "videoTag") else {
                print("fail 1")
                return}
            guard let videoTagRowValue = videoTagRow.value else {
                print("fail 2")
                return}
            
            guard let dateRow: DateRow = self.form.rowBy(tag: "dateTag") else {
                print("fail 3")
                return
            }
            guard let dateRowValue = dateRow.value else {
                print("fail 4")
                return}
            
            guard let timeRow: TimeRow = self.form.rowBy(tag: "timeTag") else {return}
            guard let timeRowValue = timeRow.value else {
                print("fail 5")
                return}
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "M-d-yyyy"
            let dateString = dateFormat.string(from: dateRowValue)
            
            let fileToBeNamed = (self.selectedPerson?.name)! + "_" + videoTagRowValue + "_" + dateString
                
                self.fileName = fileToBeNamed + ".mp4"
            
            let videoData = try? Data(contentsOf: url )
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath =
                documentsDirectory.appendingPathComponent(self.fileName)
            
            
            do {
                let videoSaved = try videoData?.write(to: dataPath, options: [])
                //                DispatchQueue.main.async {
                //                    self.performSegue(withIdentifier: "playVIdeo", sender: self)
                //                }
                
                //self.save(url: self.fileName, dataPath)
                
                self.save(vidUrl: self.fileName, dataPath, videoTag: videoTagRowValue, releaseDate: dateRowValue, releaseTime: timeRowValue, videoDataPath: dataPath)
                
                self.view.bringSubviewToFront((self.progressReport)!)
                
            }
            catch {
                print("The video did not save")
                return
            }
            
            
            
            
        }
        
        nameFileAlert.addAction(saveAction)
        
        
        self.present(nameFileAlert, animated: true, completion: nil)
    }
    
}

extension VideoAtrributesViewController: UINavigationControllerDelegate{}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
