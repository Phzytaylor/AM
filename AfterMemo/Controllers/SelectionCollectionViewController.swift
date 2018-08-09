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
import FanMenu

private let reuseIdentifier = "content"

class SelectionCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate  {
    
    
    
    
    
    
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
    
    var recipients: [Recipient] = []
    var recipentsCount = 0
    
    lazy var dateSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSDate.compare(_:))
    
        return NSSortDescriptor(key: #keyPath(Recipient.latestMemoDate), ascending: false, selector: compareSelector)
    }()
    
  
  
    
    let setingsButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "sharp_settings_white_18pt"), style:.plain, target: self, action: #selector(showSettingsMenu))
    
    
    
    
    var appBar = MDCAppBar()
    let memoHeaderView = MemoHeaderView()
    
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
    
    func configureButton(){

        self.appBar.navigationBar.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sharp_settings_white_24pt"), style: .plain, target: self, action: #selector(settingsAction(_:)))
        
        self.appBar.navigationBar.rightBarButtonItem?.tintColor = .white
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppBar()
        configureButton()
        let myImageView: UIImageView = {
            let imageView = UIImageView(image:#imageLiteral(resourceName: "iStock-174765643 (2)"))
            imageView.clipsToBounds = true
//            imageView.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: 100)
            imageView.contentMode = .scaleAspectFill
            
            return imageView
        }()
//        collectionView?.backgroundColor = .clear
//        collectionView?.backgroundView = myImageView
        
        do {
            try fetchedRC.performFetch()
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
            break;
        case .delete:
            print("I deleted")
            break;
        case . update:
            print("I updated")
            collectionView?.performBatchUpdates({
                if let indexPath = indexPath {
                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                }
                
                if let newIndexPath = newIndexPath {
                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
                }
            }, completion: nil)
            break;
        case .move:
            print("I moved")
          
            collectionView?.performBatchUpdates({
                if let indexPath = indexPath {
                    collectionView?.deleteItems(at: [IndexPath(item: indexPath.row, section: 2)])
                }
                
                if let newIndexPath = newIndexPath {
                    collectionView?.insertItems(at: [IndexPath(item: newIndexPath.row, section: 2)])
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
            print("I updated")
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
                self.addChildViewController(recordingChoiceViewController)
                recordingChoiceViewController.view.frame = cell.bounds
                cell.addSubview(recordingChoiceViewController.view)
                recordingChoiceViewController.didMove(toParentViewController: self)
//            cell.backgroundColor = .clear
            cell.backgroundView = collectionView.backgroundView
            
            
                return cell
            
            
        } else if section == 1 {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "remind", for: indexPath) as! RemindersCollectionViewCell
            
            cell.backgroundColor = .clear
            
            
           return cell
          
        }else if section == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selection", for: indexPath) as! SelectionCollectionViewCell
            cell.isSelectable = true
            //cell.selectedImageTintColor = .blue
            //cell.backgroundColor = .blue
            //let person = recipients[indexPath.row]
            let person = fetchedRC.object(at: IndexPath(item: indexPath.row, section: 0))
            guard let avatarImageValue = person.avatar as Data? else {return cell}
           
            
            guard let name = person.name else {return cell}
            let userImage = UIImage(data: avatarImageValue as Data)
            
           
            cell.userAvatarImageView.image = userImage
           
            cell.nameLabel.text = name
            
            
            

            
            cell.videoMemoImage.image = UIImage(imageLiteralResourceName: "outline_videocam_white_36pt")
            
            cell.videoMemoImage.tintColor = .black
            
            cell.triggersImage.image = UIImage(imageLiteralResourceName: "sharp_event_white_36pt")
            cell.triggersImage.tintColor = .black

            
            cell.audioMemoImage.image = #imageLiteral(resourceName: "baseline_settings_voice_white_36pt")
            cell.audioMemoImage.tintColor = .black
            cell.writtenMemoImage.image = #imageLiteral(resourceName: "outline_chat_white_18pt")
            cell.writtenMemoImage.tintColor = .black
            
            let totalCount = (person.videos?.count ?? 0) + (person.voice?.count ?? 0 ) + (person.written?.count ?? 0)
            
            cell.triggerCount.text = String(totalCount)
            cell.videoCount.text = String( person.videos?.count ?? 0)
            cell.audioCount.text = String(person.voice?.count ?? 0)
            cell.textCount.text = String(person.written?.count ?? 0)

            
            
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
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var section = indexPath.section
        
        if section == 2 {
            
          
            performSegue(withIdentifier: "fromFeed", sender: indexPath )
        }
    }
    
   
   
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
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
            footerView.backgroundColor = .clear
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
        
        guard let destinationVC = segue.destination as? MainCollectionViewController else {
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
        
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}




extension SelectionCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionViewLayout.invalidateLayout()
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
            let footerHeight: CGFloat = 50.0
            let footerWidth: CGFloat = collectionView.frame.size.width
           // let footerWidth: CGFloat = 0.0
            return CGSize(width: footerWidth, height: footerHeight)
        } else {
            return CGSize(width: 0.0, height: 0.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let section = indexPath.section
        
        var deviceOrientation = UIDevice.current.orientation
        
      if section == 0 && deviceOrientation.isLandscape == true {
        //let width = Int(collectionView.frame.width)
        
            return CGSize(width: collectionView.frame.width, height: 150)
            
      } else if section == 0 && deviceOrientation.isLandscape == false {
        let width = Int(collectionView.frame.width)
        
        return CGSize(width: width, height: 150)
      }
      else if section == 1 {let width = Int(collectionView.frame.width)
            
            return CGSize(width: collectionView.frame.width, height: 50)
            
      } else if section == 2 {
        let width = Int(collectionView.frame.width)
        
        return CGSize(width: collectionView.frame.width, height:150)
      }
        else {
            return UICollectionViewFlowLayoutAutomaticSize
        }
        
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


















