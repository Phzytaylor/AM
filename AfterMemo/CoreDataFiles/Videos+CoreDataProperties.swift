//
//  Videos+CoreDataProperties.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/31/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
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
    @NSManaged public var videoTag: String?
    @NSManaged public var recipient: Recipient?

}
