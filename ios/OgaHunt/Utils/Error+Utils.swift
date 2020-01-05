//
//  Error+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    var reason: String { return (self as NSError).localizedDescription }

    var detailedReason: String {
        let err = (self as NSError)
        return "\(err.localizedDescription)\n(Code \(code))"
    }
}
