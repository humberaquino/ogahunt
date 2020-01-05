//
//  Price+CoreDataClass.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Price)
public class Price: NSManagedObject {}

extension Price {
    func asString() -> String {
        if let amount = amount {
            return "\(amount)"
        } else {
            return "no-price"
        }
    }
}
