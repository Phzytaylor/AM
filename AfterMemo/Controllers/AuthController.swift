//
//  AuthController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/16/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import CryptoSwift

final class AuthController {
    static let serviceName = "AfterMemoService"
    static var isSignedIn: Bool {
        
        guard let currentUser = Settings.currentUser else {
            return false
        }
        
        do {
            let password = try KeychainPasswordItem(service: serviceName, account: currentUser.name).readPassword()
            
            
            return password.count > 0
        } catch {
            return false
        }
    }
    
    class func passwordHash(from name: String, password:String) -> String {
        
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(name).\(salt)".sha256()
    }
    class func signIn(_ user: User, password: String) throws {
        let finalHash = passwordHash(from: user.name, password: password)
        try KeychainPasswordItem(service: serviceName, account: user.name).savePassword(finalHash)
        print(finalHash)
        
        print("this is the user password: \(finalHash)")
        
       // Settings.currentUser = user
        
       // print(Settings.currentUser)
        
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
    
    class func signOut() throws {
        
        guard let currentUser = Settings.currentUser else {
            
            print("THERE IS NO USER")
            return
        }
        
        //TODO: Determain what will be done. If info is deleted from Keychain or just change login status.
        
        try KeychainPasswordItem(service: serviceName, account: currentUser.name).deleteItem()
       
        
        Settings.currentUser = nil
        
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
    
    class func deletePW(_ user: String) throws{
        
        
        
       try KeychainPasswordItem(service: serviceName, account: user).deleteItem()
        
        
    }
}

extension Notification.Name {
    
    static let loginStatusChanged = Notification.Name("com.Wes.auth.changed")
}













