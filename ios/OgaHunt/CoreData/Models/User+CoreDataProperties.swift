//
//  User+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var roleId: Int64
    @NSManaged public var myEvents: NSSet?
}

// MARK: Generated accessors for myEvents

extension User {
    @objc(addMyEventsObject:)
    @NSManaged public func addToMyEvents(_ value: EstateEvent)

    @objc(removeMyEventsObject:)
    @NSManaged public func removeFromMyEvents(_ value: EstateEvent)

    @objc(addMyEvents:)
    @NSManaged public func addToMyEvents(_ values: NSSet)

    @objc(removeMyEvents:)
    @NSManaged public func removeFromMyEvents(_ values: NSSet)
}
