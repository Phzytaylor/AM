//
//  ContactsTableViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/6/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import Contacts
import MaterialComponents

protocol grabbedContactInfoDelegate {
    func didChoose(name: String, email: String, number: String, photo: Data, birthday: Date)
}

class ContactsTableViewController: UITableViewController {
var grabbedContactDelegate: grabbedContactInfoDelegate!
    var contactsTestArray: [CNContact] = []
    var filteredContacts = [LovedOneContact]()
    var middleArray = [LovedOneContact]()
   
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        //Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = middleArray.filter({(contact: LovedOneContact) -> Bool in
            return contact.firstName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func fetchContacts(){
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey, CNContactBirthdayKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                request.sortOrder = CNContactSortOrder.givenName
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
                        //let thePic = contact.thumbnailImageData
                        
                        
                        
                        if contact.givenName.isEmpty || contact.givenName == " "{
                            //print("Empty Name")
                        } else {
                            self.contactsTestArray.append(contact)
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                            }
                        }
                        
                        
                            
                        
                        
                    })
                    
                    var CNnumber:String = ""
                    var CNemail:String = ""
                    var CNimageData:Data?
                    var CNBirthDay:Date?
                    
                    
                    self.contactsTestArray.forEach { (contact) in
                        let name = contact.givenName
                        if contact.emailAddresses.isEmpty {
                            let email = "none"
                            CNemail = email
                        } else {
                            let email = contact.emailAddresses.first
                            let emailString = email?.value
                            CNemail = emailString! as String
                        }
                        
                        if contact.phoneNumbers.isEmpty{
                            let number = "none"
                            CNnumber = number
                        } else {
                            let number = contact.phoneNumbers.first
                            let numberString = number?.value.stringValue
                            CNnumber = numberString!
                        }
                        if contact.thumbnailImageData == nil {
                            let imageData: Data = #imageLiteral(resourceName: "twotone_account_circle_black_48pt").pngData()!
                            CNimageData = imageData
                        } else{
                            let imageData:Data = contact.thumbnailImageData!
                            CNimageData = imageData
                        }
                        if contact.birthday == nil {
                            CNBirthDay = Date()
                        } else {
                            CNBirthDay = contact.birthday?.date
                        }
                        
                        
                        
                        self.middleArray.append(LovedOneContact(firstName: name, phoneNumber: CNnumber, email: CNemail, profileImage: CNimageData!, birthDay: CNBirthDay!))
                        
                    }
                    self.createContactsData(contacts: self.middleArray)
                    
                   // print(middleArray[0].firstName)

                    
                } catch let error {
                    print("Failed to enumerate contacts:",error)
                }
                
                
                
            } else{
                print("Access denied..")
                return
            }
        }
       
    }
    
    
    var contacts = [LovedOneContact]()
    var tableViewSource = [Character : [LovedOneContact]]()
    var headerTitles = [Character]()
    
    func createContactsData(contacts:[LovedOneContact]){
        
        
      
        print(contacts)
        tableViewSource.removeAll()
        var prevChar: Character?
        var currentBatch: [LovedOneContact]!
        contacts.forEach { contact in
            guard let firstChar = contact.firstName.first else {
                print("I failed")
                return
            }
            if prevChar != firstChar {
                if prevChar != nil {
                    tableViewSource[prevChar!] = currentBatch
                }
                prevChar = firstChar
                currentBatch = [LovedOneContact]()
            }
            currentBatch.append(contact)
        }
        
        let allKeys = Array(tableViewSource.keys)
        let sortedSymbols = allKeys.sorted(by: {$0 < $1})
        headerTitles = sortedSymbols
      
        DispatchQueue.main.async {
            
            
            self.tableView.reloadData()
        }
    }
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
    
    
    let backItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action:#selector(dismissView) )
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.navigationController?.navigationBar.isHidden = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.navigationBar.barTintColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0);
//       configureAppBar()
//        appBar.navigationBar.tintColor = .white
//        navigationController?.navigationBar.isHidden = true
        
      self.title = "Contacts"
        
        
        
//        self.navigationController?.navigationBar.isHidden = false
//        self.addChildViewController(appBar.headerViewController)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        searchController.searchBar.tintColor = .white
        

       
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField{
            textField.textColor = .blue
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true
            }
        }
        
       
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(imageLiteralResourceName: "iStock-174765643 (2)" ), for: .default)
        
       
        
        
       navigationItem.searchController = searchController
        
        
//        navigationItem.searchController?.searchBar.backgroundImage = UIImage(imageLiteralResourceName: "iStock-174765643 (2)")
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissView))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
//        appBar.navigationBar.observe(navigationItem)
        
        
        
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "TEST", style: .done, target: self, action: nil)
//
        definesPresentationContext = true
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
        
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        
        
        fetchContacts()
        
        
        
//        self.appBar.navigationBar.leftBarButtonItems = [self.backItem]
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if isFiltering() {
            return 1
        } else {
            return headerTitles.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return "Search Results"
        }
        return String(headerTitles[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
       if isFiltering() {
            return filteredContacts.count
        }
        
        
        return (tableViewSource[headerTitles[section]]?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lovedContact", for: indexPath) as! ContactLovedOneTableViewCell
        
        let cellInfo: LovedOneContact
        
        if isFiltering() {
            cellInfo = filteredContacts[indexPath.row]
        } else {
            cellInfo = tableViewSource[headerTitles[indexPath.section]]![indexPath.row]
        }
        
        
        
        cell.contactImage.image = UIImage(data: cellInfo.profileImage)
        cell.emailLabel.text = cellInfo.email
        cell.nameLabel.text = cellInfo.firstName
        cell.phoneNumberLabel.text = cellInfo.phoneNumber
//         let cellInfo = contactsTestArray[indexPath.row]
//
//        if cellInfo.emailAddresses.isEmpty {
//            cell.emailLabel.text = ""
//        } else {
//            let email = cellInfo.emailAddresses.first
//            let emalString = email?.value
//            cell.emailLabel.text = emalString! as String
//        }
//
//        if cellInfo.phoneNumbers.isEmpty {
//            cell.phoneNumberLabel.text = ""
//        } else {
//            let phoneNumber = cellInfo.phoneNumbers.first
//            let phoneNumberString = phoneNumber?.value.stringValue
//            cell.phoneNumberLabel.text = phoneNumberString
//        }
//
//        if cellInfo.thumbnailImageData == nil{
//            cell.contactImage.image = #imageLiteral(resourceName: "twotone_account_circle_black_36pt")
//        } else {
//
//            cell.contactImage.image = UIImage(data: cellInfo.thumbnailImageData!)
//        }
//
//        cell.nameLabel.text = cellInfo.givenName
//
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lovedOne: LovedOneContact
        
        if isFiltering() {
            
            lovedOne = filteredContacts[indexPath.row]
            
            grabbedContactDelegate.didChoose(name: lovedOne.firstName, email: lovedOne.email, number: lovedOne.phoneNumber, photo: lovedOne.profileImage, birthday: lovedOne.birthDay)
            
            navigationController?.dismiss(animated: true, completion: nil)
            
        } else {
            lovedOne = tableViewSource[headerTitles[indexPath.section]]![indexPath.row]
            
            grabbedContactDelegate.didChoose(name: lovedOne.firstName, email: lovedOne.email, number: lovedOne.phoneNumber, photo: lovedOne.profileImage, birthday: lovedOne.birthDay)
            
            dismissView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150.0;//Choose your custom row height
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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

//extension ContactsTableViewController {
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
//            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
//        }
//    }
//
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
//            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
//        }
//    }
//
//    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
//                                  willDecelerate decelerate: Bool) {
//        let headerView = self.appBar.headerViewController.headerView
//        if (scrollView == headerView.trackingScrollView) {
//            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
//        }
//    }
//
//    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
//                                   withVelocity velocity: CGPoint,
//                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let headerView = self.appBar.headerViewController.headerView
//        if (scrollView == headerView.trackingScrollView) {
//            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
//                                                     targetContentOffset: targetContentOffset)
//        }
//    }
//
//}

extension ContactsTableViewController: UISearchResultsUpdating {
    // MARK: -UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
