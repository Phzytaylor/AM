//
//  Userinfo+CoreDataProperties.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 2/23/19.
//  Copyright © 2019 Taylor Simpson. All rights reserved.
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
    @NSManaged public var mileStoneProgress: Double
    @NSManaged public var email: String?

}
