//
//  EstateFilter.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

struct EstateFilter {
    let name: String
    let value: String
    let predicate: NSPredicate

    // Factories
//    static func typeFilter(type: EstateType) -> EstateFilter {
//        let predicate = NSPredicate(format: "type == %@", type.rawValue)
//        return EstateFilter(name: "type", value: type.rawValue, predicate: predicate)
//    }
}
