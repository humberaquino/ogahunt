//
//  ContactSingleResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/4/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactSingleResponse: Mappable {
    var contact: ContactResponse?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        contact <- map["contact"]
    }
}
