//
//  AccountInfoViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 2/23/19.
//  Copyright © 2019 Taylor Simpson. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseDatabase

class AccountInfoViewController: FormViewController {
    let indicator = UIActivityIndicatorView()
    
    func setupConstraints() {
        let centerX = NSLayoutConstraint(item: self.indicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: self.indicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self.indicator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
        self.indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([centerX, centerY, height])
    }
    
    let dataBaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(imageLiteralResourceName: "iStock-174765643 (2)"),
                                                                    for: .default)
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationController?.navigationBar.tintColor = .white
       self.view.addSubview(indicator)
        setupConstraints()
        self.view.bringSubviewToFront(indicator)
        self.indicator.style = .whiteLarge
        self.indicator.tintColor = .black
        self.indicator.color = .black
        
        indicator.startAnimating()
        
        form +++ Section("Your Account Info")
            
            <<< TextRow() { row in
                row.title = "First Name"
                row.tag = "firstName"
                row.placeholder = "John"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            
            <<< TextRow() { row in
                row.title = "Last Name"
                row.tag = "lastName"
                row.placeholder = "Doe"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< DateRow(){ row in
                row.title = "Birthday"
                row.tag = "birthDay"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
        }
            <<< EmailRow() { row in
                row.title = "Email"
                row.tag = "email"
                row.placeholder = "you@gmail.com"
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChange
        }
            <<< PhoneRow() { row in
                row.title = "Phone Number"
                row.tag = "phoneNumber"
                row.placeholder = "1-111-1111"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
        }
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "Update Account Info"
                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = .blue
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                    
                    
                    
                    
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        
                        if let userID = Auth.auth().currentUser?.uid {
                            
                            let firstNameRow = self?.form.rowBy(tag: "firstName") as? TextRow
                            let firstName = firstNameRow?.value ?? "No First Name"
                            let lastNameRow = self?.form.rowBy(tag: "lastName") as? TextRow
                            let lastName = lastNameRow?.value ?? "No Last Name"
                            let phoneRow = self?.form.rowBy(tag: "phoneNumber") as? PhoneRow
                            let phoneNumber = phoneRow?.value ?? "no phone number"
                            let birthdayRow = self?.form.rowBy(tag: "birthDay") as? DateRow
                            let  birthDay = birthdayRow?.value ?? Date()
                            
                            let dateFormat = DateFormatter()
                            dateFormat.dateFormat = "MM-dd-yyyy"
                            let dateString = dateFormat.string(from: birthDay)
                            
                            let emailRow = self?.form.rowBy(tag: "email") as? EmailRow
                           let email = emailRow?.value ?? "no email"
                            self?.dataBaseRef.child("users").child(userID).updateChildValues(["firstName" : firstName, "lastName": lastName, "phoneNumber": phoneNumber, "birthday": dateString, "email": email], withCompletionBlock: { (error, dataRef) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Upload Error", message: "There was an error making changes. Try again later", preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    
                                    self?.present(alert, animated: true, completion: nil)
                                } else {
                                    self?.navigationController?.popViewController(animated: true)
                                }
                            })
                            
                        }
                        
          }
                    
        }
        // Do any additional setup after loading the view.
        
        
        if let userID = Auth.auth().currentUser?.uid {
           
             print(userID)
            dataBaseRef.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                 let snapDict = snapshot.value as? [String:Any]
                
                let firstName:String = snapDict?["firstName"] as? String ?? "none"
                let lastName:String = snapDict?["lastName"] as? String ?? "none"
                let phoneNumber:String = snapDict?["phoneNumber"] as? String ?? " no number"
                let birthDay:String = snapDict?["birthday"] as? String ?? "01-01-0001"
                let email:String = snapDict?["email"] as? String ?? "none"
                
                let firstNameRow = self.form.rowBy(tag: "firstName") as? TextRow
                firstNameRow?.value = firstName
                let lastNameRow = self.form.rowBy(tag: "lastName") as? TextRow
                lastNameRow?.value = lastName
                let phoneRow = self.form.rowBy(tag: "phoneNumber") as? PhoneRow
                phoneRow?.value = phoneNumber
                let birthdayRow = self.form.rowBy(tag: "birthDay") as? DateRow
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                let date = dateFormatter.date(from: birthDay) ?? Date()
                birthdayRow?.value = date
                let emailRow = self.form.rowBy(tag: "email") as? EmailRow
                emailRow?.value = email
                
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
