//
//  Userinfo+CoreDataProperties.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/7/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//
//

import Foundation
import CoreData


extension Userinfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Userinfo> {
        return NSFetchRequest<Userinfo>(entityName: "Userinfo")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?

}
