//
//  Location+CoreDataClass.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import CoreLocation
import Foundation

@objc(Location)
public class Location: NSManagedObject {}

extension Location {
    func coordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
