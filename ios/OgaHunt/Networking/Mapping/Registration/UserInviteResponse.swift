//
//  UserInviteResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInviteResponse: Mappable {
    var email: String?
    var inviteExpiresAt: Date?
    var inviteAccepted: Bool?
    var inviteAcceptedAt: Date?
    var insertedAt: Date?

    required init?(map _: Map) {}

    // Mappable
    func mapping(map: Map) {
        email <- map["email"]
        inviteExpiresAt <- (map["invite_expires_at"], DatetimeFormatterTransform())
        inviteAccepted <- map["invite_accepted"]
        inviteAcceptedAt <- (map["invite_accepted_at"], DatetimeFormatterTransform())
        insertedAt <- (map["inserted_at"], DatetimeFormatterTransform())
    }
}
