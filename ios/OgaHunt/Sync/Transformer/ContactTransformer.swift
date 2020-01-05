//
//  ContactTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/4/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

// merge: response into model -> model
// build*: model to new response -> response

extension Contact {
    func merge(contactResponse: ContactResponse) {
        id = contactResponse.id ?? -1
        teamId = contactResponse.teamId ?? -1
        firstName = contactResponse.firstName
        lastName = contactResponse.lastName
        phone1 = contactResponse.phone1
        phone2 = contactResponse.phone2
        details = contactResponse.details
        version = contactResponse.version ?? -1
    }

    func buildContactResponse() -> ContactResponse {
        let contactResponse = ContactResponse.buildEmpty()

        contactResponse.id = id
        contactResponse.details = details
        contactResponse.firstName = firstName
        contactResponse.lastName = lastName
        contactResponse.phone1 = phone1
        contactResponse.phone2 = phone2
        contactResponse.teamId = teamId
        contactResponse.version = version

        return contactResponse
    }
}

// buildEmpty: In case we want to populate the response manually
extension ContactResponse {
    static func buildEmpty() -> ContactResponse {
        return Mapper<ContactResponse>().map(JSONString: "{}")!
    }
}
