//
//  ContactResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/4/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactResponse: Mappable {
    var id: Int64?
    var teamId: Int64?
    var version: Int32?

    var firstName: String?
    var lastName: String?
    var phone1: String?
    var phone2: String?

    var details: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        // :first_name, :last_name, :phone1, :phone2, :details, :version, :team_id
        id <- map["id"]
        teamId <- map["team_id"]
        version <- map["version"]

        firstName <- map["first_name"]
        lastName <- map["last_name"]
        phone1 <- map["phone1"]
        phone2 <- map["phone2"]

        details <- map["details"]
    }

    func validate() -> ValidationResult {
        let firstNameValid = StringValidator(name: "First name", value: firstName, required: true,
                                             minLength: Contact.Limits.minNameLength, maxLength: Contact.Limits.maxNameLength).validate()

        if !firstNameValid.valid {
            return firstNameValid
        }

        let phone1Valid = StringValidator(name: "Phone 1", value: phone1, required: true,
                                          minLength: Contact.Limits.minNameLength, maxLength: Contact.Limits.maxNameLength).validate()

        if !phone1Valid.valid {
            return phone1Valid
        }

        return phone1Valid
    }
}
