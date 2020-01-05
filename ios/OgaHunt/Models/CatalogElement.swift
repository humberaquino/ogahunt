//
//  CatalogElement.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class CatalogElement {
    let name: String
    let value: EstateType

    init(name: String, value: EstateType) {
        self.name = name
        self.value = value
    }
}
