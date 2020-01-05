//
//  LocationResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 "location": {
 "longitude": 7.89,
 "latitude": 12.3456,
 "id": 1
 },
 */
class LocationResponse: Mappable {
    var id: Int64?
    var longitude: Double?
    var latitude: Double?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
    }
}
