//
//  EstateSingleResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/31/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class EstateSingleResponse: Mappable {
    var estate: EstateResponse?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        estate <- map["estate"]
    }
}
