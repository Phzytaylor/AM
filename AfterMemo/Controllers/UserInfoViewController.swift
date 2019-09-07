//
//  UserInfoViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/6/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreData

class UserInfoViewController: FormViewController {
    var firstName = ""
    var lastName = ""
    let gradient = GradientView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //tableView.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        tableView.backgroundView = gradient
        gradient.firstColor = #colorLiteral(red: 0.04111137241, green: 0.394802928, blue: 0.5176765919, alpha: 1)
        gradient.secondColor = .white

        form +++ Section("This info is for recovery and memo storage")
            
            <<< EmailRow(){ row in
                row.title = "Your Email"
                row.placeholder = "Enter a email"
                row.tag = "email"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< PasswordRow(){
                row in
                row.title = "Enter Password"
                row.placeholder = "password"
                row.tag = "password"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< PasswordRow(){
                row in
                row.title = "Verify Password"
                row.placeholder = "password"
                row.tag = "verifyPassword"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< PhoneRow(){row in
                row.title = "Phone Number"
                row.placeholder = "1-000-0000"
                row.tag = "phone"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            
            <<< DateRow() { row in
                row.title = " Your Birthday"
                row.value = Date(timeIntervalSinceReferenceDate: 0)
                row.tag = "birthdayDateTag"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save"
                
                }
                .cellSetup() {cell, row in
                    cell.backgroundColor = #colorLiteral(red: 0.04111137241, green: 0.394802928, blue: 0.5176765919, alpha: 1)
                    cell.tintColor = .white
                }
                .onCellSelection { [weak self] (cell, row) in
                    
                    
                    guard let emailRow: EmailRow = self?.form.rowBy(tag: "email") else {return}
                    guard let emailRowValue = emailRow.value else {return}
                    
                    guard let passwordRow: PasswordRow = self?.form.rowBy(tag: "password") else {return}
                    
                    guard let passwordRowValue = passwordRow.value else {return}
                    
                    guard let passwordVerifyRow: PasswordRow = self?.form.rowBy(tag: "verifyPassword") else {return}
                    
                    guard let passwordVerifyRowValue = passwordVerifyRow.value else {return}
                 
                    
                    guard let birthdayRow: DateRow = self?.form.rowBy(tag: "birthdayDateTag") else {return}
                    
                    guard let birthDayRowValue = birthdayRow.value else {return}
                    
                    guard let phoneRow: PhoneRow = self?.form.rowBy(tag: "phone") else {return}
                    guard let phoneRowValue = phoneRow.value else {return}
                    
                    print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0 && passwordRowValue == passwordVerifyRowValue{
                        
                        Auth.auth().createUser(withEmail: emailRowValue, password: passwordRowValue) { (authResult, error) in
                            // ...
                            
                            if error == nil {
                                
                                guard let userID = Auth.auth().currentUser?.uid else {return}
                                
                                let userRef = Database.database().reference().child("users").child(userID)
                                
                                let dateFormat = DateFormatter()
                                dateFormat.dateFormat = "MM-dd-yyyy"
                                let dateString = dateFormat.string(from: birthDayRowValue)
                                print("\(dateString)")
                                
                                userRef.updateChildValues(["email": emailRowValue, "phoneNumber": phoneRowValue, "birthday": dateString,"firstName": self?.firstName, "lastName": self?.lastName]  )
                                
                                UserDefaults.standard.set(true, forKey: "hasSetup")
                                
                                self?.performSegue(withIdentifier: "userInfoDone", sender: self)
                                
                            } else if error != nil {
                                
                                guard let firebaseError = error else {return}
                                
                                
                                let passwordAlert = UIAlertController(title: "Registration Error", message: firebaseError.localizedDescription, preferredStyle: .alert)
                                
                                passwordAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                
                                self?.present(passwordAlert, animated: true, completion: nil)
                                
                            }
                            
                            
                            
                            
                        }
                        
                    }
                        
                    else {
                        let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must contain values in order to save or your passwords don't match", preferredStyle: .alert)
                        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(uploadAlert, animated: true, completion: nil)
                    }
                    
                    
                    
                    
                    // Do any additional setup after loading the view.
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Userinfo")
      
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            
            if let userNameInfo = result.first as? Userinfo {
                firstName = userNameInfo.firstName ?? "none"
                lastName = userNameInfo.lastName ?? "none"
            }
            
        } catch {
            
            print("Failed")
        }
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            //header.backgroundView?.backgroundColor = UIColor.green
            header.textLabel?.textColor = UIColor.white
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
