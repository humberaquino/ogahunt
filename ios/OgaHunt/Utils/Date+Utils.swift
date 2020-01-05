//
//  Date+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/28/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Date {
    func toMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

extension NSDate {
    @objc var sectionIdentifier: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: (self as NSDate) as Date)
    }
}
