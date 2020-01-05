//
//  DateFormatter.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/30/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftDate

extension String {
    func parseDate() -> Date? {
        return toISODate()?.date
    }
}

open class DatetimeFormatterTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            return dateString.toISODate()?.date
        }
        return nil
    }

    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toISO()
        }
        return nil
    }
}

// extension Formatter {
//    static let iso8601: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
//        return formatter
//    }()
// }
