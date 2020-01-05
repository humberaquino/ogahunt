//
//  SyncTracker.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import DateToolsSwift
import Foundation

enum SyncResult {
    case runned
    case failed(reason: String)
    case skipped(reason: String)
    case error(error: Error)
}
