//
//  VoiceClass.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/11/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage



struct VoicesFromDatabase {
    
    let ref: DatabaseReference?
    let key: String?
    let lovedOne: String?
    let audioStorageURL: String?
    let audioTag: String?
    let releaseDate: String?
    let releaseTime: String?
    let uuID: String?
    let audioOnDeviceURL: String?
    let createdDate: String?
    let lovedOneEmail: String?
    let relation: String?
    let adminName: String?
    let adminEmail: String?
    
    init(lovedOne: String?, audioStorageURL: String?, audioTag: String?, releaseTime: String?, releaseDate: String?, uuID: String?, key: String? = "", audioOnDeviceURL: String?, createdDate: String?, lovedOneEmail: String?, relation: String?, adminName: String?, adminEmail: String?) {
        self.ref = nil
        self.key = key
        self.lovedOne = lovedOne
        self.audioStorageURL = audioStorageURL
        self.audioTag = audioTag
        self.releaseTime = releaseTime
        self.releaseDate = releaseDate
        self.uuID = uuID
        self.audioOnDeviceURL = audioOnDeviceURL
        self.createdDate = createdDate
        self.lovedOneEmail = lovedOneEmail
        self.relation = relation
        self.adminName = adminName
        self.adminEmail = adminEmail
    }
    
    init?(snapshot: DataSnapshot) {
        
        guard let value = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
                    let lovedOne = value["lovedOne"] as? String
                    let audioStorageURL = value["audioStorageURL"] as? String
                    let audioTag = value["audioTag"] as? String
                    let releaseDate = value["releaseDate"] as? String
                    let releaseTime = value["releaseTime"] as? String
                    let uuID = value["uuID"] as? String
                    let audioOnDeviceURL = value["audioOnDeviceURL"] as? String
                    let createdDate = value["createdDate"] as? String
                    let lovedOneEmail = value["lovedOneEmail"] as? String
                    let relation = value["relation"] as? String
                    let adminName = value["adminName"] as? String
                    let adminEmail = value["adminEmail"] as? String
        
        
//        guard
//            let value = snapshot.value as? [String: AnyObject],
//            let lovedOne = value["lovedOne"] as? String,
//            let audioStorageURL = value["audioStorageURL"] as? String,
//            let audioTag = value["audioTag"] as? String,
//            let releaseDate = value["releaseDate"] as? String,
//            let releaseTime = value["releaseTime"] as? String,
//            let uuID = value["uuID"] as? String,
//            let audioOnDeviceURL = value["audioOnDeviceURL"] as? String,
//            let createdDate = value["createdDate"] as? String,
//            let lovedOneEmail = value["lovedOneEmail"] as? String,
//            let relation = value["relation"] as? String else {
//                return nil
//        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.lovedOne = lovedOne
        self.audioStorageURL = audioStorageURL
        self.audioTag = audioTag
        self.releaseDate = releaseDate
        self.releaseTime = releaseTime
        self.uuID = uuID
        self.audioOnDeviceURL = audioOnDeviceURL
        self.createdDate = createdDate
        self.lovedOneEmail = lovedOneEmail
        self.relation = relation
        self.adminName = adminName
        self.adminEmail = adminEmail
    }
    
    func toAnyObject() -> Any {
        return [
            "lovedOne": lovedOne,
            "audioStorageURL": audioStorageURL,
            "audioTag": audioTag,
            "releaseDate": releaseDate,
            "releaseTime": releaseTime,
            "uuID": uuID,
            "audioOnDeviceURL": audioOnDeviceURL,
            "createdDate": createdDate,
            "lovedOneEmail": lovedOneEmail,
            "relation": relation,
            "adminName": adminName,
            "adminEmail": adminEmail
        ]
    }
}
