//
//  ResultResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class ResultResponse: Mappable {
    var success: Bool?
    var message: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        success <- map["success"]
        message <- map["message"]
    }
}
