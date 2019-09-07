//
//  RecipentStruct.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 3/6/19.
//  Copyright © 2019 Taylor Simpson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage



class RecipientFromDatabase {
    
    let ref: DatabaseReference?
    let key: String?
    var lovedOne: String
    var lovedOneEmail: String
    var relation: String
    var adminName: String
    var adminEmail: String
    var avatar: String
    var birthday:String
    var marraigeDate: String
    var isMarried: Bool
    var phoneNumber: String
    var avatarData: Data?
    
    init(key: String? = "", lovedOne:String, lovedOneEmail: String, relation: String, adminName: String,adminEmail: String, avatar:String, birthday:String, marriageDate:String, isMarried:Bool, phoneNumber:String, avatarData: Data?) {
        self.ref = nil
        self.key = key
        self.lovedOne = lovedOne
        self.lovedOneEmail = lovedOneEmail
        self.relation = relation
        self.adminName = adminName
        self.adminEmail = adminEmail
        self.avatar = avatar
        self.birthday = birthday
        self.marraigeDate = marriageDate
        self.isMarried = isMarried
        self.phoneNumber = phoneNumber
        self.avatarData = avatarData
        
    }
    
    
    
    
    init?(snapshot: DataSnapshot) {
        
        guard let value = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
        
  
        if let lovedOne = value["name"] as? String {
            self.lovedOne = lovedOne
            
        } else {
            self.lovedOne = ""
        }
        
       if let lovedOneEmail = value["email"] as? String {
            self.lovedOneEmail = lovedOneEmail
       } else {
        self.lovedOneEmail = "none@none.com"
        }
        
        if let relation = value["relation"] as? String {
            self.relation = relation
        } else {
            self.relation = "No relation"
        }
        
        if let adminName = value["admin"] as? String {
            self.adminName = adminName
        } else {
            self.adminName = "Unknown"
        }
        
        if let adminEmail = value["adminEmail"] as? String {
            self.adminEmail = adminEmail
        } else {
            self.adminEmail = "none@none.com"
        }
        if let avatar = value["avatar"] as? String {
            self.avatar = avatar

        } else {
            self.avatar = ""
        }
        
        if let birthday = value["birthday"] as? String {
            self.birthday = birthday
        }
        else {
            self.birthday = "01-01-0001"
        }
        if let marriageDate = value["marriageDate"] as? String  {
            self.marraigeDate = marriageDate
        } else {
            self.marraigeDate = "01-01-0001"
        }
        
        if let isMarried = value["married"] as? Bool {
            self.isMarried = isMarried
        } else {
            self.isMarried = false
        }
        if let phoneNumber = value["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = "000-000-0000"
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        
        
    }
    
    func downLoadMedia(avatar: String,completion: @escaping (_ imageData: Data)->Void) {
        let storage = Storage.storage()
        
       
        
        let httpsReference = storage.reference(forURL: avatar)
        httpsReference.getData(maxSize: 3 * 1024 * 1024) { (data, error) in
            if error == nil && data != nil {
                guard let grabbedData = data else {
                    return
                }
                
                 return completion(grabbedData)
                
            } else {
                print(error)
                
              return completion(#imageLiteral(resourceName: "sharp_account_circle_white_36pt").pngData()!)
            }
        }
        
        
    }
    
}
