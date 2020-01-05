//
//  TeamInfoResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/24/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class TeamInfoResponse: Mappable {
    var id: Int64?
    var name: String?
    var role: String?

    required init?(map _: Map) {}

    // Mappable
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        role <- map["role"]
    }

    func toTeam() -> Team? {
        guard let id = id,
            let name = name,
            let role = role else {
            return nil
        }
        return Team(name: name, id: id, role: role)
    }
}
