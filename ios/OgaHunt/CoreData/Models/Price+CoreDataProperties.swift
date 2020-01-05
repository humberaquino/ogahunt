//
//  Price+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension Price {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: "Price")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var currency: String?
    @NSManaged public var id: Int64
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var estate: Estate?
}
