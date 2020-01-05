//
//  EstateResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Foundation
import ObjectMapper

/**
 {
 "version": 1,
 "price": {
 "id": 1,
 "amount": "100000.00"
 },
 "name": "some name",
 "location": {
 "longitude": 7.89,
 "latitude": 12.3456,
 "id": 1
 },
 "id": 1,
 "details": "some details",
 "contact": {
 "version": 1,
 "phone2": null,
 "phone1": "123456",
 "last_name": "Jordan",
 "id": 1,
 "first_name": "Mike",
 "details": "Is a test detail"
 },
 "address": "some address"
 }
 */
class EstateResponse: Mappable {
    var id: Int64?
    var version: Int32?
    var currentPrice: PriceResponse?
    var name: String?
    var location: LocationResponse?
    var mainContact: ContactResponse?
    var assignedToId: Int64?
    var images: [ImageResponse]?
    var details: String?
    var address: String?

    var insertedAt: String?
    var updatedAt: String?

    var type: String?
    var status: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        version <- map["version"]
        currentPrice <- map["current_price"]
        name <- map["name"]
        location <- map["location"]
        mainContact <- map["main_contact"]
        details <- map["details"]
        address <- map["address"]
        type <- map["type"]
        status <- map["status"]
        assignedToId <- map["assigned_to"]
        images <- map["images"]
        insertedAt <- map["inserted_at"]
        updatedAt <- map["updated_at"]
    }
}
