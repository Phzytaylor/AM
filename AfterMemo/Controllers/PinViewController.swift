//
//  ViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/14/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//


// GOALS: Basic pin animations and basic auth is mostly finished. What we need to do now is detect if it is a user first time setting a pin. If it is we create a new entry into the key chain if not then we proceed to go to the next screen upon pin verification.

import UIKit
import LocalAuthentication

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
    var wrongInputCount = 0
    fileprivate var touchIDContext = LAContext()
    open var isTouchAuthenticationAvailable: Bool {
        return touchIDContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    
    open var touchAuthenticationReason = "Touch to unlock"
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        
    
       
        
    }
    
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    
    @objc func appCameBack() {
        print("App moved to foreground!")
        
        appDidComeBack = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appCameBack), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = ""
        passwordContainerView.deleteButton.setImage(#imageLiteral(resourceName: "outline_backspace_white_48pt"), for: .normal)
        
        
        
        
        passwordContainerView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        passwordContainerView.touchAuthenticationButton.tintColor = .white
        passwordContainerView.highlightedColor = .white
        passwordContainerView.deleteButton.tintColor = .white
        passwordContainerView.deleteButton.setTitleColor(.white, for: .normal)
        passwordContainerView.touchAuthenticationButton.setTitle("", for: .normal)
        
        if isTouchAuthenticationAvailable {
            passwordContainerView.touchAuthenticationButton.setImage(#imageLiteral(resourceName: "outline_fingerprint_white_48pt"), for: .normal)
        }
        
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.04111137241, green: 0.394802928, blue: 0.5176765919, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.frame = self.view.bounds
        self.view.layer.addSublayer(layer)
        
        self.view.bringSubviewToFront(self.passwordStackView)
        self.view.bringSubviewToFront(self.passwordContainerView)
        
       
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
        let user = User(name: deviceName)
        if createAndEnterLabel.tag == createPinTag {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(deviceName, forKey: "username")
                
                print(UserDefaults.standard.value(forKey: "username"))
            }
            
            do {
                //let user = User.init(name: deviceName)
                //This is a new account so we must create a new keychain with the account name and password.
              try AuthController.signIn(user, password: pinInput)
                
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
                validationFail()
                if wrongInputCount  >= 3 {
                    let pinResetMessageAlert = UIAlertController(title: "Having Trouble?", message: "It seems like you have forgotten your pin. Would you like to reset it?", preferredStyle: .alert)
                    pinResetMessageAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        guard self.isTouchAuthenticationAvailable else { return }
                        self.touchIDContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.touchAuthenticationReason) { (success, error) in
                            DispatchQueue.main.async {
                                if success {
                                    print("I WORKED")
                                    // instantiate LAContext again for avoiding the situation that PasswordContainerView stay in memory when authenticate successfully
                                    do{
                                    try
                                      
                                        
                                        AuthController.signOut()
                                        
                                       print("I SIGNED OUT")
                                        UserDefaults.standard.set(false, forKey: "hasLoginKey")
                                        UserDefaults.standard.set(false, forKey: "hasVerified")
                                        self.wrongInputCount = 0
                                        self.createAndEnterLabel.text = "Create Your Pin"
                                        self.createAndEnterLabel.tag = self.createPinTag
                                        //self.viewDidLoad()
                                    } catch {
                                        print("It didn't work!")
                                        return
                                    }
                                    
                                    self.touchIDContext = LAContext()
                                } else {
                                    print("there was an error!")
                                }
                                
                            }
                        }
                    }))
                    pinResetMessageAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                  self.present(pinResetMessageAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func checkLogin(userName: String, password: String) -> Bool {
        
        guard userName == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        print("TAG This is the password right?: \(password)")
        
        do {
            
            let passwordItem = KeychainPasswordItem(service: AuthController.serviceName, account: userName)
            
            let keychainPassword = try passwordItem.readPassword()
            print("TAG PASSWORD KEYCHAIN: \(keychainPassword)")
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         wrongInputCount = 0
    }

}

extension PinViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
    let pinVerified = UserDefaults.standard.bool(forKey: "hasVerified")
        
        if !pinVerified && firstPin == nil {
           firstPin = input
            print("This is the input: \(input)")
            createAndEnterLabel.text = "Verify Pin"
            passwordContainerView.clearInput()
            
            
        } else if !pinVerified && firstPin != nil {
            if input == firstPin {
                
                UserDefaults.standard.set(true, forKey: "hasVerified")
                
                loginAction(pinInput: input)
            } else {
                print("Pin did not match.")
                validationFail()
                let pinError = UIAlertController(title: "Error", message: "Your pin doesn't match.", preferredStyle: .alert)
                pinError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(pinError, animated: true, completion: nil)
                
                ///
            }
        }else if pinVerified{
            
            
                loginAction(pinInput: input)
                print("This is the wrong pin count: \(wrongInputCount)")
               
                
            
            
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
            self.performSegue(withIdentifier: "toMain", sender: self)
            
        } else {
            passwordContainerView.clearInput()
            
            var generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            validationFail()
            
            
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
        wrongInputCount += 1
        
    }
}


