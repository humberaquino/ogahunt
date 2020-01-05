//
//  RoleResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class RoleResponse: Mappable {
    var id: Int64?
    var name: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
