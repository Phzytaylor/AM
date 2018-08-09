//
//  Written+CoreDataProperties.swift
//  
//
//  Created by Taylor Simpson on 6/15/18.
//
//

import Foundation
import CoreData


extension Written {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Written> {
        return NSFetchRequest<Written>(entityName: "Written")
    }

    @NSManaged public var dateToBeReleased: NSDate?
    @NSManaged public var isVideo: Bool
    @NSManaged public var isVoiceMemo: Bool
    @NSManaged public var isWrittenMemo: Bool
    @NSManaged public var memoText: String?
    @NSManaged public var releaseTime: NSDate?
    @NSManaged public var uuID: String?
    @NSManaged public var writtenTag: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var recipient: Recipient?

}
