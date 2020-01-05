//
//  TeamEventsResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class EstateEventListResponse: Mappable {
    var events: [EstateEventResponse]?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        events <- map["events"]
    }
}
