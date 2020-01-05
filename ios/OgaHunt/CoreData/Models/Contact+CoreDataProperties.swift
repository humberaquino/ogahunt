//
//  Contact+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension Contact {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var details: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var isDirty: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var phone1: String?
    @NSManaged public var phone2: String?
    @NSManaged public var syncedAt: NSDate?
    @NSManaged public var teamId: Int64
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var version: Int32
    @NSManaged public var estates: NSSet?
}

// MARK: Generated accessors for estates

extension Contact {
    @objc(addEstatesObject:)
    @NSManaged public func addToEstates(_ value: Estate)

    @objc(removeEstatesObject:)
    @NSManaged public func removeFromEstates(_ value: Estate)

    @objc(addEstates:)
    @NSManaged public func addToEstates(_ values: NSSet)

    @objc(removeEstates:)
    @NSManaged public func removeFromEstates(_ values: NSSet)
}
