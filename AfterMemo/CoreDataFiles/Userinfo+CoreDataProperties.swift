//
//  Userinfo+CoreDataProperties.swift
//  
//
//  Created by Taylor Simpson on 6/15/18.
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
