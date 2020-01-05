//
//  BaseSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import DateToolsSwift
import Foundation

class BaseSyncher {
    let syncType: SyncType
    var lastSyncResult: SyncResult?
    var lastSyncDate: Date?
    var resyncThreaholdSecs: TimeInterval = 10 * 60 // 10 min by default

    init(syncType: SyncType) {
        self.syncType = syncType
    }

    func shouldRun(intent: SyncIntent) -> Result {
        // Force: if all || type is the same -> run
        if intent.force && (intent.type == .all || intent.type == syncType) {
            return Result(yes: true, reason: nil)
        }

        // Normal
        // If intent in not all nor synctype, skip
//        if !(intent.type == .all || intent.type == syncType) {
//            return Result(yes: false, reason: "Intent if for a different type: \(intent.type)")
//        }

        // Did it run already and is all or type
        guard let lastSyncDate = lastSyncDate else {
            return Result(yes: true, reason: nil)
        }

        // Normal: If time pased
        let duration = Date().timeIntervalSince(lastSyncDate)
        if duration > resyncThreaholdSecs {
            return Result(yes: true, reason: nil)
        } else {
            return Result(yes: false, reason: "\(Int(resyncThreaholdSecs - duration))")
        }
    }

    func markSyncWith(result: SyncResult) {
        lastSyncResult = result
        lastSyncDate = Date()
    }
}
