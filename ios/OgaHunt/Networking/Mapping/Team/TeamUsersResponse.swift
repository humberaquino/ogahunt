//
//  TeamUsersResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class TeamUsersResponse: Mappable {
    var users: [TeamUserResponse]?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        users <- map["users"]
    }
}
