//
//  PhoneNumberUtils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/15/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import PhoneNumberKit

struct PhoneNumberUtils {
    static func format(number: String?) -> String? {
        guard let number = number else { return nil }

        let phoneNumberKit = PhoneNumberKit()

        do {
            let phoneNumber = try phoneNumberKit.parse(number)
//            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(number, withRegion: "PY", ignoreType: true)

            return phoneNumberKit.format(phoneNumber, toType: .international)
        } catch {
            print("Generic parser error")
            return number
        }
    }
}
