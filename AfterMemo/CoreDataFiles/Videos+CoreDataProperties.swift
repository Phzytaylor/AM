//
//  Videos+CoreDataProperties.swift
//  
//
//  Created by Taylor Simpson on 6/15/18.
//
//

import Foundation
import CoreData


extension Videos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Videos> {
        return NSFetchRequest<Videos>(entityName: "Videos")
    }

    @NSManaged public var dateToBeReleased: NSDate?
    @NSManaged public var isVideo: Bool
    @NSManaged public var isVoiceMemo: Bool
    @NSManaged public var isWrittenMemo: Bool
    @NSManaged public var releaseTime: NSDate?
    @NSManaged public var thumbNail: NSData?
    @NSManaged public var urlPath: String?
    @NSManaged public var uuID: String?
    @NSManaged public var videoTag: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var recipient: Recipient?

}
