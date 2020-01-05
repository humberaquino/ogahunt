//
//  Contact+CoreDataClass.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/11/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Contact)
public class Contact: NSManagedObject {}

extension Contact {
    static let NoName = "no-name"
    struct Limits {
        static let minNameLength = 3
        static let maxNameLength = 200
    }

    var alreadySaved: Bool {
        return id >= 0
    }

    func fullname() -> String {
        if let firstName = self.firstName,
            let lastName = self.lastName {
            return "\(firstName) \(lastName)"
        } else {
            if let firstName = self.firstName {
                return "\(firstName)"
            } else if let lastName = self.lastName {
                return "\(lastName)"
            } else {
                return Contact.NoName
            }
        }
    }
}
