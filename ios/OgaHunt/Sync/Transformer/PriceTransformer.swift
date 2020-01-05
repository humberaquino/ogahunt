//
//  PriceTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Price {
    func merge(priceResponse: PriceResponse) {
        if let id = priceResponse.id {
            self.id = id
        }
        amount = NSDecimalNumber(string: priceResponse.amount)
        currency = priceResponse.currency
        notes = priceResponse.notes
    }
}

extension PriceResponse {}
