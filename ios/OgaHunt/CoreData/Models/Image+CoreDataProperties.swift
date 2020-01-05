//
//  Image+CoreDataProperties.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

extension Image {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var contentType: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var expires: NSDate?
    @NSManaged public var id: Int64
    @NSManaged public var imageDeleted: Bool
    @NSManaged public var imageURL: String?
    @NSManaged public var insertedAt: NSDate?
    @NSManaged public var localPath: String?
    @NSManaged public var signedImageURL: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var estate: Estate?
}
