//
//  SettingsResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class SettingsResponse: Mappable {
    var userStatuses: [UserStatusResponse]?
    var roles: [RoleResponse]?
    var estateTypes: [EstateTypeResponse]?
    var estateStatuses: [EstateStatusResponse]?
    var currencies: [CurrencyResponse]?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        userStatuses <- map["user_statuses"]
        roles <- map["roles"]
        estateTypes <- map["estate_types"]
        estateStatuses <- map["estate_status"]
        currencies <- map["currencies"]
    }
}
