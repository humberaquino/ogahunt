//
//  Estate+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension Estate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Estate> {
        return NSFetchRequest<Estate>(entityName: "Estate")
    }

    @NSManaged public var address: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var details: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var isDirty: Bool
    @NSManaged public var isDraft: Bool
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var synchedAt: NSDate?
    @NSManaged public var type: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var version: Int32
    @NSManaged public var assignedTo: User?
    @NSManaged public var createdBy: User?
    @NSManaged public var currentPrice: Price?
    @NSManaged public var events: NSSet?
    @NSManaged public var images: NSOrderedSet?
    @NSManaged public var location: Location?
    @NSManaged public var mainContact: Contact?
    @NSManaged public var prices: NSSet?
    @NSManaged public var updatedBy: User?
}

// MARK: Generated accessors for events

extension Estate {
    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: EstateEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: EstateEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)
}

// MARK: Generated accessors for images

extension Estate {
    @objc(insertObject:inImagesAtIndex:)
    @NSManaged public func insertIntoImages(_ value: Image, at idx: Int)

    @objc(removeObjectFromImagesAtIndex:)
    @NSManaged public func removeFromImages(at idx: Int)

    @objc(insertImages:atIndexes:)
    @NSManaged public func insertIntoImages(_ values: [Image], at indexes: NSIndexSet)

    @objc(removeImagesAtIndexes:)
    @NSManaged public func removeFromImages(at indexes: NSIndexSet)

    @objc(replaceObjectInImagesAtIndex:withObject:)
    @NSManaged public func replaceImages(at idx: Int, with value: Image)

    @objc(replaceImagesAtIndexes:withImages:)
    @NSManaged public func replaceImages(at indexes: NSIndexSet, with values: [Image])

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSOrderedSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSOrderedSet)
}

// MARK: Generated accessors for prices

extension Estate {
    @objc(addPricesObject:)
    @NSManaged public func addToPrices(_ value: Price)

    @objc(removePricesObject:)
    @NSManaged public func removeFromPrices(_ value: Price)

    @objc(addPrices:)
    @NSManaged public func addToPrices(_ values: NSSet)

    @objc(removePrices:)
    @NSManaged public func removeFromPrices(_ values: NSSet)
}
