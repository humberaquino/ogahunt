//
//  Decimal+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/30/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}
