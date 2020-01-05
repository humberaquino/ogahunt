//
//  SyncJob.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

enum SyncType {
    case all
    case settings
    case team
    case contacts
    case estate
    case events
}

struct SyncIntent {
    let type: SyncType
    var force: Bool
}
