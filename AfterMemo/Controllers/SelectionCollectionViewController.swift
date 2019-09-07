//
//  SelectionCollectionViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/23/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards
import CoreData
import FirebaseAuth
import Macaw


private let reuseIdentifier = "content"

class SelectionCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, SelectionDelegate  {
    func editLovedOnePressed(_ cell: SelectionCollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
       
        currentPerson = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
        self.performSegue(withIdentifier: "editLovedOne", sender: self)
    }
    
    
    
    
    let defaults = UserDefaults.standard
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    
    lazy var fetchedRC: NSFetchedResultsController<Recipient> = {
        
        
        
        let fetchRequest:NSFetchRequest<Recipient> = Recipient.fetchRequest()
        
        let reversedDescriptor = dateSortDescriptor.reversedSortDescriptor as! NSSortDescriptor
        
        
        fetchRequest.sortDescriptors = [dateSortDescriptor]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:managedContext , sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchedResultsController.delegate = self
        
        
        
        return fetchedResultsController
    }()
    
    // private var fetchedRC: NSFetchedResultsController<Recipient>!
    
    let randomArray = ["one", "two", "tree"]
    
    // var fetchRequest: NSFetchRequest<Recipient>?
    @IBAction func unwindToSelection(segue:UIStoryboardSegue) {
        
    }
    var recipients: [Recipient] = []
    var recipentsCount = 0
    var dateString: String?
    var reminderArray: [(String, Recipient)] = []
    var seconds = 5.0
    var timer = Timer()
    var isTimerRunning = false
    //this is the current loved on in the alert
    var currentPerson: Recipient?
    lazy var dateSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSDate.compare(_:))
        
        return NSSortDescriptor(key: #keyPath(Recipient.latestMemoDate), ascending: false, selector: compareSelector)
    }()
    
    
    
    
    let setingsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "sharp_settings_white_18pt"), style:.plain, target: self, action: #selector(showSettingsMenu))
    
    
    var setUpBool = false
    
    var appBar = MDCAppBar()
    let memoHeaderView = MemoHeaderView()
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(SelectionCollectionViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if reminderArray.isEmpty == false {
            var currentTuple = reminderArray.randomElement()
            dateString = currentTuple?.0
            currentPerson = currentTuple?.1
            
            UIView.animate(withDuration: 2.5, delay: 0, options: [.autoreverse,.repeat], animations: {
                self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 1)])
                //                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? RemindersCollectionViewCell else {
                //                        return
                //                    }
                //                    cell.frame.origin.y -= 5
                
            }, completion: nil)
            
        }
//        if seconds < 1 {
//            timer.invalidate()
//        } else {
//            seconds -= 1
//
//        }
        
        
        
        
        
    }
    
    
    func selectAction(){
        let createMemoActions = UIAlertController(title: "Create", message: "Pick a memo type.", preferredStyle: .actionSheet)
        createMemoActions.addAction(UIAlertAction(title: "Video", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "toVideo", sender: self)
        }))
        
        createMemoActions.addAction(UIAlertAction(title: "Audio", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "toaudio", sender: self)
        }))
        
        createMemoActions.addAction(UIAlertAction(title: "Text", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "toWritten", sender: self)
        }))
        
        createMemoActions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(createMemoActions, animated: true, completion: nil)
        
    }
    
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
        
        headerView.trackingScrollView = self.collectionView
        
        appBar.addSubviewsToParent()
        
        appBar.headerViewController.layoutDelegate = self
        
        
    }
    
    
    
    @IBAction func settingsAction(_ sender: Any) {
        
        showSettingsMenu()
    }
    
    @objc func showSettingsMenu() {
        
        
        let settingsChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        self.performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        //collectionView?.reloadData()
        
    }
    
    func reminderDate(fromDate:Date, toDate:Date) -> Int {
        let dateComponentsFormatter = DateComponentsFormatter()
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: fromDate)
        let date2 = calendar.startOfDay(for: toDate)
        
        let components = calendar.dateComponents([.year,.month], from: date1, to: date2).month
        guard let monthsAway = components?.magnitude else {
            return -100
        }
        
        return Int(monthsAway)
    }
    
    func configureButton(){
        
        self.appBar.navigationBar.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sharp_settings_white_24pt"), style: .plain, target: self, action: #selector(settingsAction(_:)))
        
        self.appBar.navigationBar.rightBarButtonItem?.tintColor = .white
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    //TODO: We want to look at date the person was married and how far away it is.
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppBar()
        configureButton()
        memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        memoHeaderView.imageViewCenterCon?.isActive = true
        
        memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: memoHeaderView.centerYAnchor, constant: -30.0)
        
        memoHeaderView.imageViewYCon?.isActive = true
        
        memoHeaderView.imageView.layoutIfNeeded()
        
        print("The initial Height is: \(screenHeight)")
        print("The initial Width is: \(screenWidth)")
        
        let myImageView: UIImageView = {
            let imageView = UIImageView(image:#imageLiteral(resourceName: "iStock-174765643 (2)"))
            imageView.clipsToBounds = true
            //            imageView.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: 100)
            imageView.contentMode = .scaleAspectFill
            
            return imageView
        }()
        //        collectionView?.backgroundColor = .clear
        //        collectionView?.backgroundView = myImageView
        dateString = "Welcome to AfterMemo"
        do {
            try fetchedRC.performFetch()
            let dateComponentsFormatter = DateComponentsFormatter()
            if let objects = fetchedRC.fetchedObjects {
                let calendar = Calendar.current
                for person in objects{
                    if person.relation == "Husband" || person.relation == "Wife" {
                        print("Grabbing Date")
                        //Trying to find how far the date us away and change the reminder based n that set a reminder
                        
                        guard let dateMarried = person.mariageDate as Date? else {
                            // date is nil, ignore this entry:
                            
                            continue
                        }
                        
                        let monthsAway = reminderDate(fromDate: Date(), toDate: dateMarried)
                        // Replace the hour (time) of both dates with 00:00
                        
                        if monthsAway <= 1 && monthsAway > -1 {
                            guard let name = person.name else {
                                continue
                            }
                            
                            reminderArray.append((("Your annaversary with \(name) is \(monthsAway) months away. Create a memo."), person))
                            dateString = "Your annaversary with \(name) is \(monthsAway) months away. Create a memo."
                        }
                        
                    }
                    else {
                        print("not married!!!")
                        
                        guard let lastMemoDate = person.latestMemoDate else {
                            continue
                        }
                        
                        
                        
                        let recordDate = reminderDate(fromDate: lastMemoDate as Date, toDate: Date())
                        guard let name = person.name else {
                            continue
                        }
                        
                        if recordDate >= 1 {
                            print("You recorded a memo \(recordDate) months ago for \(name). Make a new one.")
                            
                            let lastRecordedString = "You recorded a memo \(recordDate) months ago for \(name). Make a new one."
                            
                            reminderArray.append((lastRecordedString,person))
                        }
                        
                        guard let birthday = person.age else {
                            continue
                        }
                        
                        let monthsUntilBirthday = reminderDate(fromDate: Date(), toDate: birthday as Date)
                        
                        if monthsUntilBirthday <= 1 {
                            let birthdayString = "\(name)'s birthday is \(monthsUntilBirthday) month(s) away. Make a memo."
                            reminderArray.append((birthdayString,person))
                        }
  
                    }
                }
                
              runTimer()
            }
            
        } catch let error as NSError{
            print("Could not fetch\(error), \(error.userInfo)")
        }
        
        
        //        self.appBar.navigationBar.leftBarButtonItems = [setingsButton]
        
        print("I AM SECOND")
        //recipients.removeAll()
        
        //loadPeople()
        // contactController.grabbedContactDelegate = self
        
        
        
        print("This is the user + \(Auth.auth().currentUser?.uid)")
        
        self.collectionView?.register(UINib(nibName: "RemindersCollectionViewCells", bundle: nil), forCellWithReuseIdentifier: "remind")
        
        self.collectionView?.register(UINib(nibName: "SellectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "selection")
        
        
        
        
        // self.title = "AfterMemo"
        
        
        
        //        let logo = UIImage(imageLiteralResourceName: "AM Big Logo")
        //
        //        let imageView = UIImageView(image: logo)
        
        
        
        // imageView.backgroundColor = .red
        
        
        //        imageView.contentMode = .scaleAspectFit
        
        
        
        //       self.navigationItem.titleView = imageView
        
        
        
        
        // self.navigationItem.rightBarButtonItem = setingsButton
        
        
        
        // let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30.0, weight: .semibold)]
        
        //appBar.navigationBar.titleTextAttributes = attributes
        //        UINavigationBar.appearance().titleTextAttributes = attributes
        
        
        
        
        //        self.addChildViewController(appBar.headerViewController)
        //        self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView
        //        appBar.addSubviewsToParent()
        //
        //        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        //
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //        self.collectionView!.register(MDCCardCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("I Will Make A CHANGE")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("I made a change")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("I inserted")
            
            collectionView.reloadSections([2])
            break;
        case .delete:
            print("I deleted")
            guard let numberOfPeople = collectionView?.numberOfItems(inSection: 2) else{
                return
            }
            
            
            collectionView?.performBatchUpdates({
                if numberOfPeople > 1 {
                    for i in (0...numberOfPeople - 1).reversed() {
                        
                        collectionView?.deleteItems(at: [IndexPath(item: i, section: 2)])
                    }
                    let count = fetchedRC.fetchedObjects?.count ?? 0
                    
                    for items in 0...count - 1 {
                        
                        collectionView?.insertItems(at: [IndexPath(item: items, section: 2)])
                    }
                    
                } else{
                    
                    collectionView.reloadSections([2])
                }
                
                
                
                
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                //                }
            }, completion: nil)
            break;
        case . update:
            print("I updated")
            
            guard let numberOfPeople = collectionView?.numberOfItems(inSection: 2) else{
                return
            }
            
           
            collectionView?.performBatchUpdates({
                if numberOfPeople > 1 {
                for i in (0...numberOfPeople - 1).reversed() {
                    
                    collectionView?.deleteItems(at: [IndexPath(item: i, section: 2)])
                }
                let count = fetchedRC.fetchedObjects?.count ?? 0
                
                for items in 0...count - 1 {
                    
                    collectionView?.insertItems(at: [IndexPath(item: items, section: 2)])
                    }
                    
                } else{
                    
                   collectionView.reloadSections([2])
                }
                
                
                
                
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                //                }
            }, completion: nil) 
                
            
            break;
        case .move:
            print("I moved")
            guard let numberOfPeople = collectionView?.numberOfItems(inSection: 2) else{
                return
            }
            
            collectionView?.performBatchUpdates({
                //                if let indexPath = indexPath {
                //                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                //                }
                //
                //                if let newIndexPath = newIndexPath {
                //                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                if numberOfPeople > 1 {
                for i in (0...numberOfPeople - 1).reversed() {
                    
                    collectionView?.deleteItems(at: [IndexPath(item: i, section: 2)])
                    }
                let count = fetchedRC.fetchedObjects?.count ?? 0
                if count > 1 {
                for items in 0...count - 1 {
                    
                    collectionView?.insertItems(at: [IndexPath(item: items, section: 2)])
                }
                
                    }
                    
                }else  {
                    
                    collectionView.reloadSections([2])
                }
                
            }, completion: nil)
            
            break;
        default:
            print("I don't know")
        }
        
        
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("I inserted")
            break;
        case .delete:
            print("I deleted")
            break;
        case .update:
            print("I updated for sure")
            break;
        case .move:
            print("I moved!")
            break;
        default:
            print("I don't know")
        }
    }
    
    func loadPeople(){
        
        recipients.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //guard let model = managedContext.persistentStoreCoordinator?.managedObjectModel, let fetchRequestPrimer = model.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Recipient> else {return}
        
        let myFetch = Recipient.fetchRequest() as NSFetchRequest
        
        
        
        
        guard let reversedDescriptor = dateSortDescriptor.reversedSortDescriptor as? NSSortDescriptor else {
            print("This is not working")
            return}
        
        
        myFetch.sortDescriptors = [dateSortDescriptor]
        
        do {
            
            
            fetchedRC = NSFetchedResultsController(fetchRequest: myFetch, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedRC.delegate = self
            try fetchedRC.performFetch()
            
            /*  myFetch.shouldRefreshRefetchedObjects = true
             recipients =
             try managedContext.fetch(myFetch)
             
             recipentsCount = recipients.count
             collectionView?.reloadData() */
            
        } catch let error as NSError{
            print("Could not fetch\(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        // Get the new view controller using [segue destinationViewController].
    //        // Pass the selected object to the new view controller.
    //    }
    //
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            return 1
        } else if section == 1{
            return 1
            
            
        }
        else if section == 2 {
            let count = fetchedRC.fetchedObjects?.count ?? 0
            return count
        } else {
            return 0
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var section = indexPath.section
        
        
        if section == 0 {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath)
            
            let recordingChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "recordingChoice") as! RecordingChoiceCollectionViewController
            self.addChild(recordingChoiceViewController)
            recordingChoiceViewController.view.frame = cell.bounds
            cell.addSubview(recordingChoiceViewController.view)
            recordingChoiceViewController.didMove(toParent: self)
            //            cell.backgroundColor = .clear
            cell.backgroundView = collectionView.backgroundView
            
            
            
            return cell
            
            
            
            
        } else if section == 1 {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "remind", for: indexPath) as! RemindersCollectionViewCell
            
            cell.reminderLabel.text = self.dateString
            
            //            cell.backgroundColor = .clear
            
            
            return cell
            
        }else if section == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selection", for: indexPath) as! SelectionCollectionViewCell
            cell.isSelectable = false
            cell.delegate = self
            //cell.selectedImageTintColor = .blue
            //cell.backgroundColor = .blue
            //let person = recipients[indexPath.row]
            let person = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
            
            print("The person is \(person.name)")
            
            guard let name = person.name else {return cell}
            
            cell.nameLabel.text = name
            
            
            
            
            
            cell.videoMemoImage.image = UIImage(imageLiteralResourceName: "video-icon")
            
            cell.videoMemoImage.tintColor = .black
            
            cell.triggersImage.image = UIImage(imageLiteralResourceName: "cal-icon")
            cell.triggersImage.tintColor = .black
            
            
            cell.audioMemoImage.image = UIImage(imageLiteralResourceName: "audio-icon")
            cell.audioMemoImage.tintColor = .black
            cell.writtenMemoImage.image = UIImage(imageLiteralResourceName: "note-icon")
            cell.writtenMemoImage.tintColor = .black
            
            let totalCount = (person.videos?.count ?? 0) + (person.voice?.count ?? 0 ) + (person.written?.count ?? 0)
            
            cell.triggerCount.text = String(totalCount)
            cell.videoCount.text = String( person.videos?.count ?? 0)
            cell.audioCount.text = String(person.voice?.count ?? 0)
            cell.textCount.text = String(person.written?.count ?? 0)
            cell.relationLabel.text = person.relation ?? ""
            
            guard let avatarImageValue = person.avatar as Data? else {
                print("/////////////")
                print(person.avatar.debugDescription)
                print("////////////")
                return cell}
            
            
            
            let userImage = UIImage(data: avatarImageValue as Data)
            
            
            cell.userAvatarImageView.image = userImage
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! SelectionCollectionViewCell
            
            return cell
            
        }
        
        
        
        // Configure the cell
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        defaults.set(false, forKey: "didFire")
    }
    
    func saveRelation(lovedOne: Recipient, indexPath:IndexPath){
        let addRelationAlert = UIAlertController(title: "No Relation Set", message: "You haven't set a relation for this person Yet", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Update Relation", style: .default) { (alertAction) in
            let textField = addRelationAlert.textFields![0] as UITextField
            
            guard let relationText = textField.text else {
                return
            }
            
            if relationText.isEmpty {
                
                print("Can't save")
                
                let emptyAlert = UIAlertController(title: "Error", message: "You must enter a relation", preferredStyle: .alert)
                
                let emptyAlertAction = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                    
                    self.present(addRelationAlert, animated: true, completion: nil)
                    
                })
                
                emptyAlert.addAction(emptyAlertAction)
                
                self.present(emptyAlert, animated: true, completion: nil)
                
            } else {
                print("Time to save")
                
                lovedOne.relation = relationText
                
                do {
                    try lovedOne.managedObjectContext?.save()
                    
                    self.performSegue(withIdentifier: "fromFeed", sender: indexPath )
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addRelationAlert.addTextField { (textField) in
            textField.placeholder = "Enter your relation to \(lovedOne.name ?? "them")"
        }
        
        addRelationAlert.addAction(action)
        addRelationAlert.addAction(cancelAction)
        self.present(addRelationAlert, animated: true, completion: nil)
        
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var section = indexPath.section
        if section == 1 {
            if dateString != "Welcome to AfterMemo" {
                self.selectAction()
            }
        }
        if section == 2 {
            
            let selectedPerson = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
            
            if selectedPerson.relation == nil {
                
                saveRelation(lovedOne: selectedPerson, indexPath: indexPath)
                
            } else {
                
                performSegue(withIdentifier: "fromFeed", sender: indexPath )
                
            }
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionView.elementKindSectionHeader:
            //3
            
            let section = indexPath.section
            if section == 0 {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: "AfterMemoFooter", for: indexPath)
                
                
                
                
                footerView.isHidden = true
                
                return footerView
            }else
                if section == 1 {
                    
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                     withReuseIdentifier: "AfterMemoFooter", for: indexPath)
                    
                    footerView.isHidden = true
                    
                    return footerView
                    
                    
                    
                } else if section == 2 {
                    
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                     withReuseIdentifier: "AfterMemoFooter", for: indexPath)
                    
                    
                    
                    footerView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
                    return footerView
                    
                } else {
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                     withReuseIdentifier: "AfterMemoFooter",
                                                                                     for: indexPath)
                    footerView.isHidden = true
                    
                    return footerView
            }
        default:
            //4
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "AfterMemoFooter",
                                                                             for: indexPath)
            footerView.isHidden = true
            
            return footerView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromFeed" {
            
            guard let destinationVC = segue.destination as? MemoListViewController else {
                return
            }
            
            guard let indexPath = sender as? IndexPath else { return }
            
            //let selectedPerson = recipients[indexPath.row]
            let selectedPerson = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
            
            //let collectionCell = collectionView?.cellForItem(at: indexPath)
            
            
            
            destinationVC.passedRecipient = selectedPerson }
        
        if segue.identifier == "toSettings" {
            
            guard let destinationController = segue.destination as? SettingsViewController else {
                return
            }
            
           
            
            
        }
        
        if segue.identifier == "toWritten" {
            guard let destinationController = segue.destination as? WrittenMemoViewController else {
                return
            }
            
            destinationController.passedSender = self
            destinationController.selectedPerson = currentPerson
        }
        
        if segue.identifier == "toVideo" {
            guard let destinationController = segue.destination as? VideoAtrributesViewController else {
                return
            }
            
            destinationController.passedSender = self
            print("The sender was: \(destinationController.passedSender)")
            destinationController.selectedPerson = currentPerson
        }
        
        if segue.identifier == "toaudio" {
            guard let destinationController = segue.destination as? VoiceMemoAtrributeViewController else {
                return
            }
            
            destinationController.passedSender = self
            destinationController.selectedPerson = currentPerson
        }
        
        if segue.identifier == "editLovedOne" {
            
            guard let destinationController = segue.destination as? LovedOneCreationViewController else {
                
                return
            }
           
            destinationController.passedSender = self
            destinationController.passedPerson = currentPerson
        }
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
   
    
}




extension SelectionCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    /* override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
     collectionViewLayout.invalidateLayout()
     
     // Get main screen bounds
     let screenSize: CGRect = UIScreen.main.bounds
     
     let screenWidth = screenSize.width
     let screenHeight = screenSize.height
     
     print("Screen width = \(screenWidth), screen height = \(screenHeight)")
     
     switch toInterfaceOrientation {
     case .portrait:
     //do something
     
     if screenHeight == 812.0 {
     memoHeaderView.imageView.frame = CGRect(x: 155, y: 40, width: 70, height: 70)
     
     } else if screenHeight == 375.0 {
     
     memoHeaderView.imageView.frame = CGRect(x: 155, y: 15, width: 70, height: 70)
     }
     
     break
     case .portraitUpsideDown:
     //do something
     break
     case .landscapeLeft:
     //do something
     if screenHeight == 812.0{
     memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
     
     } else if screenHeight == 667.0 {
     memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
     }
     
     break
     case .landscapeRight:
     //do something
     if screenHeight == 812.0{
     memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
     
     } else if screenHeight == 667.0 {
     memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
     }
     
     break
     case .unknown:
     //default
     break
     }
     } */
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        super.didRotate(from: fromInterfaceOrientation)
        collectionViewLayout.invalidateLayout()
        print("Screen width = \(screenWidth), screen height = \(screenHeight)")
        //        memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        //        memoHeaderView.imageViewCenterCon?.isActive = true
        //
        //        memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        
        memoHeaderView.imageViewYCon?.isActive = true
        
        memoHeaderView.imageView.layoutIfNeeded()
        
        //        switch fromInterfaceOrientation {
        //        case .portrait:
        //            //do something
        //
        //            memoHeaderView.imageViewCenterCon = memoHeaderView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        //            memoHeaderView.imageViewCenterCon?.isActive = true
        //
        //            memoHeaderView.imageViewYCon = memoHeaderView.imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        //
        //            memoHeaderView.imageViewYCon?.isActive = true
        //
        //            if screenHeight == 812.0 {
        //                memoHeaderView.imageView.frame = CGRect(x: 155, y: 15, width: 70, height: 70)
        //
        //            } else if screenHeight == 375.0 {
        //                memoHeaderView.imageView.frame = CGRect(x: 380, y: 15, width: 70, height: 70)
        //
        //            }
        //
        //            break
        //        case .portraitUpsideDown:
        //            //do something
        //            break
        //        case .landscapeLeft:
        //            //do something
        //            if screenHeight == 812.0{
        //                print("I Switched")
        //                memoHeaderView.imageView.frame = CGRect(x: 155, y: 30, width: 70, height: 70)
        //
        //            } else if screenHeight == 667.0 {
        //                memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
        //            }
        //
        //            break
        //        case .landscapeRight:
        //            //do something
        //            if screenHeight == 812.0{
        //                memoHeaderView.imageView.frame = CGRect(x: 155, y: 30, width: 70, height: 70)
        //
        //            } else if screenHeight == 667.0 {
        //                memoHeaderView.imageView.frame = CGRect(x: 380, y: 30, width: 70, height: 70)
        //            }
        //
        //            break
        //        case .unknown:
        //            //default
        //            break
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let count: Int = self.collectionView(collectionView, numberOfItemsInSection: section)
        
        if section == 0 {
            let footerHeight: CGFloat = 0.0
            //let footerWidth: CGFloat = collectionView.frame.size.width
            let footerWidth: CGFloat = 0.0
            return CGSize(width: footerWidth, height: footerHeight)
            
        } else if section == 1 {
            let footerHeight: CGFloat = 0.0
            //let footerWidth: CGFloat = collectionView.frame.size.width
            let footerWidth: CGFloat = 0.0
            return CGSize(width: footerWidth, height: footerHeight)
        } else if section == 2 {
            let footerHeight: CGFloat = 20.0
            let footerWidth: CGFloat = collectionView.frame.size.width
            // let footerWidth: CGFloat = 0.0
            return CGSize(width: footerWidth, height: footerHeight)
        } else {
            return CGSize(width: 0.0, height: 0.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let section = indexPath.section
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        
        switch (section,orientation) {
        case (0,UIInterfaceOrientation.landscapeLeft), (0,UIInterfaceOrientation.landscapeRight):
            return CGSize(width: collectionView.frame.width, height: 210)
        case (0,UIInterfaceOrientation.portrait), (0,UIInterfaceOrientation.portraitUpsideDown):
            return CGSize(width: collectionView.frame.width, height: 150)
            
        case (1,UIInterfaceOrientation.landscapeRight),(1,UIInterfaceOrientation.landscapeLeft), (1, UIInterfaceOrientation.portraitUpsideDown), (1, UIInterfaceOrientation.portrait),(1,UIInterfaceOrientation.unknown):
            let width = Int(collectionView.frame.width)
            
            return CGSize(width: collectionView.frame.width, height: 100)
        case (2,UIInterfaceOrientation.landscapeRight),(2,UIInterfaceOrientation.landscapeLeft), (2, UIInterfaceOrientation.portraitUpsideDown), (2, UIInterfaceOrientation.portrait),(2,UIInterfaceOrientation.unknown):
            let width = Int(collectionView.frame.width)
            
            
            
            return CGSize(width: collectionView.frame.width, height: 150)
        default:
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        
        //      if section == 0 && deviceOrientation.isLandscape {
        //        //let width = Int(collectionView.frame.width)
        //
        //
        //
        //            return CGSize(width: collectionView.frame.width, height: 200)
        //
        //      } else if section == 0 && deviceOrientation.isLandscape == false {
        //        let width = Int(collectionView.frame.width)
        //
        //        return CGSize(width: width, height: 150)
        //      }
        //      else if section == 1 {let width = Int(collectionView.frame.width)
        //
        //            return CGSize(width: collectionView.frame.width, height: 50)
        //
        //      } else if section == 2 {
        //        let width = Int(collectionView.frame.width)
        //
        //        return CGSize(width: collectionView.frame.width, height:150)
        //      }
        //        else {
        //            return UICollectionViewFlowLayoutAutomaticSize
        //        }
        
    }
}
extension SelectionCollectionViewController: MDCFlexibleHeaderViewLayoutDelegate {
    
    public func flexibleHeaderViewController(_ flexibleHeaderViewController: MDCFlexibleHeaderViewController, flexibleHeaderViewFrameDidChange flexibleHeaderView: MDCFlexibleHeaderView) {
        //        memoHeaderView.update(withScrollPhasePercentage: flexibleHeaderView.scrollPhasePercentage)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }
    
    
    
    
    
}


















