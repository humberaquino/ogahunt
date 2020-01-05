//
//  EstateEventResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class EstateEventResponse: Mappable {
    var id: Int64?
    var estateId: Int64?
    var byUserId: Int64?
    var changeType: String?
    var changeMap: [String: Any]?
    var change: String?
    var insertedAt: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        estateId <- map["estate_id"]
        changeType <- map["change_type"]
        changeMap <- map["change"]

        if let changeMap = changeMap {
            let changeJSON = JSON(changeMap)
            change = changeJSON.rawString()
        }

        byUserId <- map["by_user_id"]
        insertedAt <- map["inserted_at"]
    }
}
