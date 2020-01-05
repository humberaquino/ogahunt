//
//  DispatchQueue+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
