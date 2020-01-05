//
//  LocationTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/4/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

extension Location {
    func merge(locationResponse: LocationResponse) {
        if let latitude = locationResponse.latitude {
            self.latitude = latitude
        }
        if let id = locationResponse.id {
            self.id = id
        }
        if let longitude = locationResponse.longitude {
            self.longitude = longitude
        }
    }
}

extension LocationResponse {
    static func buildEmpty() -> LocationResponse {
        return Mapper<LocationResponse>().map(JSONString: "{}")!
    }
}
