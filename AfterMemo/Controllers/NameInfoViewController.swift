//
//  NameInfoViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/5/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData

protocol LastPageDelegate {
    func didSave(isSaved:Bool)
}

class NameInfoViewController: UIViewController, UITextFieldDelegate {
      var lastPageDelegate: LastPageDelegate!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextLabel: AnimatedMaskLabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveAction(_ sender: Any) {
        
        guard let nameText = firstNameTextField.text else {return}
        guard let lastText = lastNameTextField.text else {return}
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "pinScreen") as! ViewController
//
//        controller.firstName = nameText
//        controller.lastName = lastText
//
        save(firstName: nameText, lastName: lastText)
        
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextLabel.didMoveToWindow()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextLabel.isHidden = true
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        guard let nameText = firstNameTextField.text else {return}
//        guard let lastText = lastNameTextField.text else {return}
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "pinScreen") as! ViewController
//
//        controller.firstName = nameText
//        controller.lastName = lastText
//
//        save(firstName: nameText, lastName: lastText)
        
        
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    func save(firstName: String, lastName: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        do {
            
            
            let person = Userinfo(context: managedContext)
            
           
            
            
            person.firstName = firstName
            person.lastName = lastName
            
            
            
            
            
            do {
                try managedContext.save()
                nextLabel.isHidden = false
                 self.view.endEditing(true)
                print(" I saved")
                saveButton.isHidden = true
                lastPageDelegate.didSave(isSaved: true)
                
                
                
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
