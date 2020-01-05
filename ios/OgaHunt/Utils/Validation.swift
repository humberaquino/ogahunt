//
//  Validation.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

struct ValidationResult {
    let valid: Bool
    let reason: String?
}

enum ValidationResultError: Error {
    case cantValidate(reason: String)
}

struct StringValidator {
    let name: String
    let value: String?
    let required: Bool?
    let minLength: Int?
    let maxLength: Int?

    func validate() -> ValidationResult {
        if let required = required {
            if required {
                if value == nil {
                    return ValidationResult(valid: false, reason: "Undefined \(name)")
                }

                let trimmedValue = value!.trimmingCharacters(in: CharacterSet.whitespaces)
                if trimmedValue.isEmpty {
                    return ValidationResult(valid: false, reason: "Empty \(name)")
                }
            } else {
                // Not required and is empty, which is valid
                return ValidationResult(valid: true, reason: nil)
            }
        }

        if let minLength = minLength {
            if value == nil {
                return ValidationResult(valid: false, reason: "\(name) is empty and the minimum length is \(minLength) characters")
            }

            let trimmedValue = value!.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmedValue.count < minLength {
                return ValidationResult(valid: false, reason: "\(name) shorter than \(minLength) characters. Current: \(trimmedValue.count)")
            }
        }

        if let maxLength = maxLength {
            if value != nil {
                let trimmedValue = value!.trimmingCharacters(in: CharacterSet.whitespaces)
                if trimmedValue.count > maxLength {
                    return ValidationResult(valid: false, reason: "\(name) larger than \(maxLength) characters. Current: \(trimmedValue.count)")
                }
            }
        }

        return ValidationResult(valid: true, reason: nil)
    }
}
