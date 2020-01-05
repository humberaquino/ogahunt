//
//  ContactsListResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactListResponse: Mappable {
    var contacts: [ContactResponse]?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        contacts <- map["contacts"]
    }
}
