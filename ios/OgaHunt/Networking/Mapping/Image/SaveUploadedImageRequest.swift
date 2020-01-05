//
//  SaveUploadedImageRequest.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

import ObjectMapper

class SaveUploadedImageRequest: Mappable {
    var estateId: Int64?
    var resourceName: String?
    var saveEvent: Bool?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        estateId <- map["estate_id"]
        resourceName <- map["resource_name"]
        saveEvent <- map["save_event"]
    }
}
