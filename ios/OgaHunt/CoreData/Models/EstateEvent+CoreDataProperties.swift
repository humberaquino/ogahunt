//
//  EstateEvent+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension EstateEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EstateEvent> {
        return NSFetchRequest<EstateEvent>(entityName: "EstateEvent")
    }

    @NSManaged public var change: String?
    @NSManaged public var changeType: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var byUser: User?
    @NSManaged public var estate: Estate?
}
