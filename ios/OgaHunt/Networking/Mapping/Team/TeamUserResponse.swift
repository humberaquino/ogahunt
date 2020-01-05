//
//  TeamUserResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class TeamUserResponse: Mappable {
    var id: Int64?
    var roleId: Int64?
    var name: String?
    var email: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        roleId <- map["role_id"]
        name <- map["name"]
        email <- map["email"]
    }
}
