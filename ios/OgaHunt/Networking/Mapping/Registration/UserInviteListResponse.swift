//
//  UserInviteListResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInviteListResponse: Mappable {
    var invitations: [UserInviteResponse]?

    required init?(map _: Map) {}

    // Mappable
    func mapping(map: Map) {
        invitations <- map["invitations"]
    }
}
