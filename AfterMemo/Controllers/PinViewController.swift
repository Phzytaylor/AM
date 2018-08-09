//
//  ViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/14/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//


// GOALS: Basic pin animations and basic auth is mostly finished. What we need to do now is detect if it is a user first time setting a pin. If it is we create a new entry into the key chain if not then we proceed to go to the next screen upon pin verification.

import UIKit

class PinViewController: UIViewController {


    @IBOutlet weak var createAndEnterLabel: UILabel!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    let createPinTag = 0
    let enterPinTag = 1
    let verifyPinTag = 2
    let deviceName = UIDevice.current.name
    var appDidComeBack = false
    var didDismiss = false
    
    var firstPin: String?
    
    var firstName: String? {
        didSet{
            print(firstName)
        }
    }
    
    var lastName: String? {
        didSet{
            print(lastName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    
       
        
    }
    
    @objc func appCameBack() {
        print("App moved to foreground!")
        
        appDidComeBack = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appCameBack), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "DELETE"
        
        
        passwordContainerView.tintColor = .red
        passwordContainerView.highlightedColor = .black
       
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        let hasVerified = UserDefaults.standard.bool(forKey: "hasVerified")
        
        print(hasLogin)
        
        if hasLogin {
            createAndEnterLabel.text = "Enter Pin"
            createAndEnterLabel.tag = enterPinTag
       }
//        else if !hasVerified {
//            createAndEnterLabel.text = "Verify Pin"
//            createAndEnterLabel.tag = verifyPinTag
//
               else {
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
            
            let hasFinishedSetup = UserDefaults.standard.bool(forKey: "hasSetup")
            
            if !hasFinishedSetup {
                performSegue(withIdentifier: "userInfo", sender: self)
                
            }else {
            
                self.performSegue(withIdentifier: "toMain", sender: self)
                
            }
            
        } else if createAndEnterLabel.tag == enterPinTag {
            
            // TODO: CHECK THE LOGIN FUNCTION
            
          var storedPassword = AuthController.passwordHash(from: deviceName, password: pinInput)
            
            if checkLogin(userName: deviceName, password: storedPassword){
                print("I DID IT!")
                
                if self.appDidComeBack == false {
                    
                    performSegue(withIdentifier: "toMain", sender: self)
                    
                } else if self.appDidComeBack == true {
                    
                    print(self.view.superview)
                    self.dismiss(animated: true) {
                        print("I dismmised")
                        self.didDismiss = true
                    }
                    
                    if didDismiss == false {
                        performSegue(withIdentifier: "toMain", sender: self)
                    }
                }
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

extension PinViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
    let pinVerified = UserDefaults.standard.bool(forKey: "hasVerified")
        
        if !pinVerified && firstPin == nil {
           firstPin = input
            
            createAndEnterLabel.text = "Verify Pin"
            passwordContainerView.clearInput()
            
            
        } else if !pinVerified && firstPin != nil {
            if input == firstPin {
                
                UserDefaults.standard.set(true, forKey: "hasVerified")
                
                loginAction(pinInput: input)
            }
        } else {
            loginAction(pinInput: input)
            
        }
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

private extension PinViewController {
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


