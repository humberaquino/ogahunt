//
//  CurrencyUtils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/15/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

struct CurrencyUtils {
    static func formattedLatestPrice(price: Price?) -> String? {
        guard let latestPrice = price else { return nil }
        let price = latestPrice.amount
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","

        let formattedNumber = numberFormatter.string(from: price!)
        return formattedNumber
    }

    static func formattedDecimalPrice(price: String) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        let dec = NSDecimalNumber(string: price)
        let formattedNumber = numberFormatter.string(from: dec)
        return formattedNumber
    }
}
