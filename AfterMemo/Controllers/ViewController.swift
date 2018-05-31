//
//  ViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/14/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//


// GOALS: Basic pin animations and basic auth is mostly finished. What we need to do now is detect if it is a user first time setting a pin. If it is we create a new entry into the key chain if not then we proceed to go to the next screen upon pin verification.

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var createAndEnterLabel: UILabel!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    let createPinTag = 0
    let enterPinTag = 1
    let deviceName = UIDevice.current.name
    
    override func viewWillAppear(_ animated: Bool) {
        
     passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "DELETE"
        
        
        passwordContainerView.tintColor = .red
        passwordContainerView.highlightedColor = .black
        
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        print(hasLogin)
        
        if hasLogin {
            createAndEnterLabel.text = "Enter Pin"
            createAndEnterLabel.tag = enterPinTag
        } else{
            
            createAndEnterLabel.text = "Create Your Pin"
            createAndEnterLabel.tag = createPinTag
        }
        
//        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
//            
//        }
        
        
        
    }
    
    func loginAction(pinInput: String) {
        
        if createAndEnterLabel.tag == createPinTag {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(deviceName, forKey: "username")
                
                print(UserDefaults.standard.value(forKey: "username"))
            }
            
            do {
                //let user = User.init(name: deviceName)
                //This is a new account so we must create a new keychain with the account name and password.
              try AuthController.signIn(deviceName, password: pinInput)
                
            }catch {
                print("Error signing in: \(error.localizedDescription)")
            }
            
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            
            self.performSegue(withIdentifier: "toMain", sender: self)
            
        } else if createAndEnterLabel.tag == enterPinTag {
            
            // TODO: CHECK THE LOGIN FUNCTION
            
          var storedPassword = AuthController.passwordHash(from: deviceName, password: pinInput)
            
            if checkLogin(userName: deviceName, password: storedPassword){
                print("I DID IT!")
                
                performSegue(withIdentifier: "toMain", sender: self)
            } else {
                // animates the dots to show that the password is incorrect
                passwordContainerView.wrongPassword()
                var generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    
    func checkLogin(userName: String, password: String) -> Bool {
        
        guard userName == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        do {
            
            let passwordItem = KeychainPasswordItem(service: AuthController.serviceName, account: userName)
            
            let keychainPassword = try passwordItem.readPassword()
            
            return password == keychainPassword
        } catch {
            
            fatalError("Error reading password from keychain - \(error)")
        }
        return false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        loginAction(pinInput: input)
//        if validation(input) {
//            validationSuccess()
//        } else {
//            validationFail()
//        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
            
            var generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

private extension ViewController {
    func validation(_ input: String) -> Bool {
        return input == "123456"
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}


