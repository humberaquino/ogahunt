//
//  Location+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude != rhs.latitude && lhs.longitude != rhs.longitude
    }
}
