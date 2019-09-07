//
//  ContactsClass.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/6/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class LovedOneContact {
    let firstName: String
    //let lastName: String
    let phoneNumber: String
    let email: String
    let profileImage: Data
    let birthDay: Date
    init(firstName:String, phoneNumber:String, email:String, profileImage:Data, birthDay:Date) {
        self.firstName = firstName
        self.birthDay = birthDay
        self.phoneNumber = phoneNumber
        self.email = email
        self.profileImage = profileImage
    }
}
