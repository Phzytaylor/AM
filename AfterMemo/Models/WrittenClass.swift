//
//  WrittenClass.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/11/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage



struct WrittenFromDatabase {
    
    let ref: DatabaseReference?
    let key: String
    let lovedOne: String
    let memoTag: String
    let releaseDate: String
    let releaseTime: String
    let uuID: String
    let memoText: String
    let createdDate: String
    let lovedOneEmail: String
    
    init(lovedOne: String, memoTag: String, releaseTime: String, releaseDate: String, uuID: String, key: String = "", memoText: String, createdDate: String, lovedOneEmail: String) {
        self.ref = nil
        self.key = key
        self.lovedOne = lovedOne
        self.memoTag = memoTag
        self.releaseTime = releaseTime
        self.releaseDate = releaseDate
        self.uuID = uuID
        self.memoText = memoText
        self.createdDate = createdDate
        self.lovedOneEmail = lovedOneEmail
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let lovedOne = value["lovedOne"] as? String,
            let memoTag = value["memoTag"] as? String,
            let releaseDate = value["releaseDate"] as? String,
            let releaseTime = value["releaseTime"] as? String,
            let uuID = value["uuID"] as? String,
            let memoText = value["memoText"] as? String,
            let createdDate = value["createdDate"] as? String,
            let lovedOneEmail = value["lovedOneEmail"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.lovedOne = lovedOne
        self.memoTag = memoTag
        self.releaseDate = releaseDate
        self.releaseTime = releaseTime
        self.uuID = uuID
        self.memoText = memoText
        self.createdDate = createdDate
        self.lovedOneEmail = lovedOneEmail
    }
    
    func toAnyObject() -> Any {
        return [
            "lovedOne": lovedOne,
            "memoTag": memoTag,
            "releaseDate": releaseDate,
            "releaseTime": releaseTime,
            "uuID": uuID,
            "memoText": memoText,
            "createdDate": createdDate,
            "lovedOneEmail": lovedOneEmail
        ]
    }
}

