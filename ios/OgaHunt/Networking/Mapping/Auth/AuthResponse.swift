//
//  AuthSuccessResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/24/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthResponse: Mappable {
    var success: Bool?
    var userId: Int64?
    var token: String?
    var teams: [TeamInfoResponse]?
    var errors: String?

    required init?(map _: Map) {}

    // Mappable
    func mapping(map: Map) {
        success <- map["success"]
        userId <- map["user.id"]
        token <- map["user.token"]
        teams <- map["user.teams"]
        errors <- map["errors"]
    }
}
