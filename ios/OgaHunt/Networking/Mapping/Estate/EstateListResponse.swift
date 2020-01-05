//
//  EstateListResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class EstateListResponse: Mappable {
    var estates: [EstateResponse]?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        estates <- map["estates"]
    }
}
