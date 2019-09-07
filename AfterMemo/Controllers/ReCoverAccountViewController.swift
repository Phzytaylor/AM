//
//  ReCoverAccountViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 3/4/19.
//  Copyright © 2019 Taylor Simpson. All rights reserved.
//


import UIKit
import Eureka
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreData
import MaterialComponents
class ReCoverAccountViewController: FormViewController {
    var firstName = ""
    var lastName = ""
    let gradient = GradientView()
    var lovedPeople: [RecipientFromDatabase] = []
    
    
    func errorAlertView(title: String, message: String) {
        
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        errorAlert.addAction(okAction)
        
        self.present(errorAlert, animated: true)
    }
    
    
    func saveRecoveredData(first:String, last:String, number:String, email: String, birthday: String, completionHandler: @escaping(Bool)->Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        do {
            
            let person = Userinfo(context: managedContext)
            person.firstName = first
            person.lastName = last
            person.email = email
            
                try managedContext.save()
                UserDefaults.standard.set(true, forKey: "hasSetup")
            
            completionHandler(true)
            
            

        }catch let error as NSError {
            completionHandler(false)
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func saveRecoveredLovedOnes(lovedOne:RecipientFromDatabase, imageData: Data, completionHandler: @escaping(Bool)->Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let dateFormater =  DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"
        let birthdayDate = dateFormater.date(from: lovedOne.birthday) ?? Date()
        let marriageDate = dateFormater.date(from: lovedOne.marraigeDate) ?? Date()
        
        
        
        //TODO DOWNLOAD IMAGE
        
        do {
            let fetchedLovedOne = Recipient(context: managedContext)
            fetchedLovedOne.name = lovedOne.lovedOne
            fetchedLovedOne.email = lovedOne.lovedOneEmail
            fetchedLovedOne.relation = lovedOne.relation
            fetchedLovedOne.adminName = lovedOne.adminName
            fetchedLovedOne.adminEmail = lovedOne.adminEmail
            fetchedLovedOne.avatar = imageData as NSData
            fetchedLovedOne.age = birthdayDate as NSDate
            fetchedLovedOne.mariageDate = marriageDate as NSDate
            fetchedLovedOne.married = lovedOne.isMarried
            fetchedLovedOne.phoneNumber = lovedOne.phoneNumber
            
             try managedContext.save()
            
            completionHandler(true)
            
        } catch let error as NSError {
    completionHandler(false)
    print("Could not save. \(error), \(error.userInfo)")
    }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //tableView.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        tableView.backgroundView = gradient
        gradient.firstColor = #colorLiteral(red: 0.04111137241, green: 0.394802928, blue: 0.5176765919, alpha: 1)
        gradient.secondColor = .white
        tableView.separatorStyle = .singleLine
        
        
        
        
        
        form +++ Section("Info For Recovery")
            <<< EmailRow(){ row in
                row.title = "Your Email"
                row.placeholder = "For password reset or account recovery"
                row.tag = "email"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                }.cellSetup({ (cell, row) in
                   
                  
                }).cellUpdate({ (cell, row) in
                    
                    
                })
            +++ Section()
            <<< PasswordRow(){
                row in
                row.title = "Enter Password"
                row.placeholder = "password"
                row.tag = "password"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }.cellSetup({ (cell, row) in
                    
                })
            +++ Section()
            <<< PasswordRow(){
                row in
                row.title = "Verify Password"
                row.placeholder = "password"
                row.tag = "verifyPassword"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }.cellSetup({ (cell, row) in
                })

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
                    button.setTitle("Recover", for: .normal)
                    button.backgroundColor = .black
                    button.addTarget(self, action: #selector(self.recoverAccount), for: .touchUpInside)
                }
                section.header = header
            }
        
            +++ Section(){ section in
                var header = HeaderFooterView<UIView>(.class) // most flexible way to set up a header using any view type
                header.height = { 50 }  // height can be calculated
                let button = MDCButton()
                

                header.onSetupView = { view, section in  // each time the view is about to be
                    view.addSubview(button)
                    button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30.0).isActive = true
                    button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30.0).isActive = true
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.setTitle("Reset Password", for: .normal)
                    button.backgroundColor = .black
                    button.addTarget(self, action: #selector(self.recoverPassword), for: .touchUpInside)
                }
                section.header = header
        }
                    
        
        
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
    
    
    @objc func recoverAccount() {
        
        guard let emailRow: EmailRow = self.form.rowBy(tag: "email") else {return}
        guard let emailRowValue = emailRow.value else {return}
        
        guard let passwordRow: PasswordRow = self.form.rowBy(tag: "password") else {return}
        
        guard let passwordRowValue = passwordRow.value else {return}
        
        guard let passwordVerifyRow: PasswordRow = self.form.rowBy(tag: "verifyPassword") else {return}
        
        guard let passwordVerifyRowValue = passwordVerifyRow.value else {return}
        
        if form.validate().isEmpty && passwordRowValue == passwordVerifyRowValue {
            
            Auth.auth().signIn(withEmail: emailRowValue, password: passwordVerifyRowValue, completion: { (result, error) in
                if error == nil {
                    guard let userID = Auth.auth().currentUser?.uid else {return}
                    
                    let userRef = Database.database().reference().child("users").child(userID)
                    
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        let userInfoDict = snapshot.value as? [String : AnyObject] ?? [:]
                        
                        let firstName = userInfoDict["firstName"] as? String ?? ""
                        let lastName = userInfoDict["lastName"] as? String ?? ""
                        let email = userInfoDict["email"] as? String ?? ""
                        
                        let phoneNumber = userInfoDict["phoneNumber"] as? String ?? ""
                        
                        let birthday = userInfoDict["birthday"] as? String ?? ""
                        
                        self.saveRecoveredData(first: firstName, last: lastName, number: phoneNumber, email: email, birthday: birthday, completionHandler: { (saved) in
                            if saved {
                                print("I saved")
                                let loveOneRef = Database.database().reference().child("users").child(userID).child("lovedOnes")
                                
                                loveOneRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.exists() {
                                        
                                        var newLovedOnesArray = [String]()
                                        for child in snapshot.children {
                                            
                                            guard let name = child as? DataSnapshot else {
                                                continue
                                            }
                                            
                                            newLovedOnesArray.append(name.key)
                                            
                                        }
                                        
                                        for person in newLovedOnesArray{
                                            
                                            loveOneRef.child(person).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
                                                
                                                let lovedOneObject = RecipientFromDatabase(snapshot: snapshot)
                                                
                                                if let avatarString = lovedOneObject?.avatar {
                                                    
                                                    lovedOneObject?.downLoadMedia(avatar: avatarString, completion: { (imageData) in
                                                        self.saveRecoveredLovedOnes(lovedOne: lovedOneObject!, imageData: imageData, completionHandler: { (saved) in
                                                            print("I am saved \(saved)")
                                                        })
                                                    })
                                                }
                                                
                                            })
                                            
                                        }
                                        
                                    }
                                    
                                    self.performSegue(withIdentifier: "toPin", sender: self)
                                })
                            } else {
                                print("Not saved")
                            }
                        })
                    })
                } else {
                    print(error?.localizedDescription)
                }
            })
        }else {
                                    let uploadAlert = UIAlertController(title: "Input Error", message: "All fields must contain values in order to save or your passwords don't match", preferredStyle: .alert)
                                    uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(uploadAlert, animated: true, completion: nil)
        }
    }
    
    @objc func recoverPassword(){
        guard let emailRow: EmailRow = self.form.rowBy(tag: "email") else {return}
        guard let emailRowValue = emailRow.value else {
            
            self.errorAlertView(title: "Input Error", message: "You must enter a valid email.")
            return}
        if emailRowValue.isEmpty == false {
            
            Auth.auth().sendPasswordReset(withEmail: emailRowValue) { error in
                
                if let error = error {
                    print(error.localizedDescription)
                    
                    self.errorAlertView(title: "Error", message: error.localizedDescription)
                }
            }
            
        } else {
            self.errorAlertView(title: "Input Error", message: "You must enter a valid email.")
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
