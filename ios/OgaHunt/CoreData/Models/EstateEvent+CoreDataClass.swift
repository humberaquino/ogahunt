//
//  EstateEvent+CoreDataClass.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

@objc(EstateEvent)
public class EstateEvent: NSManagedObject {
    @objc
    var formattedInsertedAt: String? {
        guard let insertedAt = self.insertedAt as? Date else {
            return nil
        }
        let dateFormatter = DateFormatter()
        // Apple suggested locale-aware technique:
        // dateFormatter.dateStyle = .ShortStyle
        // dateFormatter.timeStyle = .NoStyle
        // ..or to stick to your original question:
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: insertedAt)
    }
}
