//
//  NewUser.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class RegisterRequest: Mappable {
    var email: String?
    var name: String?
    var password: String?
    var confirmedPassword: String?

    required init?(map _: Map) {}

    // Mappable
    func mapping(map: Map) {
        email <- map["email"]
        name <- map["name"]
        password <- map["password"]
        confirmedPassword <- map["password_confirmation"]
    }

    static func buildEmpty() -> RegisterRequest {
        return RegisterRequest(JSONString: "{}")!
    }
}
