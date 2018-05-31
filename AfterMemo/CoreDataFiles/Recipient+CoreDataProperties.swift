//
//  Recipient+CoreDataProperties.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/31/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//
//

import Foundation
import CoreData


extension Recipient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipient> {
        return NSFetchRequest<Recipient>(entityName: "Recipient")
    }

    @NSManaged public var age: NSDate?
    @NSManaged public var avatar: NSData?
    @NSManaged public var name: String?
    @NSManaged public var videos: NSOrderedSet?
    @NSManaged public var voice: NSOrderedSet?
    @NSManaged public var written: NSOrderedSet?

}

// MARK: Generated accessors for videos
extension Recipient {

    @objc(insertObject:inVideosAtIndex:)
    @NSManaged public func insertIntoVideos(_ value: Videos, at idx: Int)

    @objc(removeObjectFromVideosAtIndex:)
    @NSManaged public func removeFromVideos(at idx: Int)

    @objc(insertVideos:atIndexes:)
    @NSManaged public func insertIntoVideos(_ values: [Videos], at indexes: NSIndexSet)

    @objc(removeVideosAtIndexes:)
    @NSManaged public func removeFromVideos(at indexes: NSIndexSet)

    @objc(replaceObjectInVideosAtIndex:withObject:)
    @NSManaged public func replaceVideos(at idx: Int, with value: Videos)

    @objc(replaceVideosAtIndexes:withVideos:)
    @NSManaged public func replaceVideos(at indexes: NSIndexSet, with values: [Videos])

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Videos)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Videos)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSOrderedSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSOrderedSet)

}

// MARK: Generated accessors for voice
extension Recipient {

    @objc(insertObject:inVoiceAtIndex:)
    @NSManaged public func insertIntoVoice(_ value: VoiceMemos, at idx: Int)

    @objc(removeObjectFromVoiceAtIndex:)
    @NSManaged public func removeFromVoice(at idx: Int)

    @objc(insertVoice:atIndexes:)
    @NSManaged public func insertIntoVoice(_ values: [VoiceMemos], at indexes: NSIndexSet)

    @objc(removeVoiceAtIndexes:)
    @NSManaged public func removeFromVoice(at indexes: NSIndexSet)

    @objc(replaceObjectInVoiceAtIndex:withObject:)
    @NSManaged public func replaceVoice(at idx: Int, with value: VoiceMemos)

    @objc(replaceVoiceAtIndexes:withVoice:)
    @NSManaged public func replaceVoice(at indexes: NSIndexSet, with values: [VoiceMemos])

    @objc(addVoiceObject:)
    @NSManaged public func addToVoice(_ value: VoiceMemos)

    @objc(removeVoiceObject:)
    @NSManaged public func removeFromVoice(_ value: VoiceMemos)

    @objc(addVoice:)
    @NSManaged public func addToVoice(_ values: NSOrderedSet)

    @objc(removeVoice:)
    @NSManaged public func removeFromVoice(_ values: NSOrderedSet)

}

// MARK: Generated accessors for written
extension Recipient {

    @objc(insertObject:inWrittenAtIndex:)
    @NSManaged public func insertIntoWritten(_ value: Written, at idx: Int)

    @objc(removeObjectFromWrittenAtIndex:)
    @NSManaged public func removeFromWritten(at idx: Int)

    @objc(insertWritten:atIndexes:)
    @NSManaged public func insertIntoWritten(_ values: [Written], at indexes: NSIndexSet)

    @objc(removeWrittenAtIndexes:)
    @NSManaged public func removeFromWritten(at indexes: NSIndexSet)

    @objc(replaceObjectInWrittenAtIndex:withObject:)
    @NSManaged public func replaceWritten(at idx: Int, with value: Written)

    @objc(replaceWrittenAtIndexes:withWritten:)
    @NSManaged public func replaceWritten(at indexes: NSIndexSet, with values: [Written])

    @objc(addWrittenObject:)
    @NSManaged public func addToWritten(_ value: Written)

    @objc(removeWrittenObject:)
    @NSManaged public func removeFromWritten(_ value: Written)

    @objc(addWritten:)
    @NSManaged public func addToWritten(_ values: NSOrderedSet)

    @objc(removeWritten:)
    @NSManaged public func removeFromWritten(_ values: NSOrderedSet)

}
