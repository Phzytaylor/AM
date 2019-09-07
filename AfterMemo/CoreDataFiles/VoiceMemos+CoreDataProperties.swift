//
//  VoiceMemos+CoreDataProperties.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 9/22/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//
//

import Foundation
import CoreData

extension VoiceMemos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoiceMemos> {
        return NSFetchRequest<VoiceMemos>(entityName: "VoiceMemos")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var dateToBeReleased: NSDate?
    @NSManaged public var isVideo: Bool
    @NSManaged public var isVoiceMemo: Bool
    @NSManaged public var isWrittenMemo: Bool
    @NSManaged public var mileStone: String?
    @NSManaged public var releaseTime: NSDate?
    @NSManaged public var urlPath: String?
    @NSManaged public var uuID: String?
    @NSManaged public var recipient: Recipient?

}
