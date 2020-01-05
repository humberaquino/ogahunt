//
//  PriceRepsonse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 {
 "price": {
 "id": 1,
 "amount": "100000.00"
 },
 */

class PriceResponse: Mappable {
    var id: Int64?
    var amount: String?
    var currencyId: Int64?
    var currency: String?
    var notes: String?
    var insertedAt: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        amount <- map["amount"]
        currencyId <- map["currency_id"]
        notes <- map["notes"]
        insertedAt <- map["inserted_at"]
        currency <- map["currency"]
    }

    static func buildEmpty() -> PriceResponse? {
        return PriceResponse(JSONString: "{}")
    }
}
