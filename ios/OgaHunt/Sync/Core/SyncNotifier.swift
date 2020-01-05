//
//  SyncMasterInterface.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let fireSync = Notification.Name("to.sync.fire")
    static let stopSync = Notification.Name("to.sync.stop")

    static let downloadEstateImages = Notification.Name("to.download.estate.images")
}

extension Notification.Name {
    static let syncSuccess = Notification.Name("from.sync.success")
    static let syncFailure = Notification.Name("from.sync.failure")
    static let syncSkipped = Notification.Name("from.sync.skipped")
    static let syncImagesDownloaded = Notification.Name("from.sync.imagesDownloaded")
}

class SyncNotifier {
    struct Keys {
        static let syncType = "syncType"
        static let force = "force"
        static let estateId = "estateId"
    }

    static func fireNormalSync() {
        fireTeamSync()
        fireContacsSync()
    }

    static func fireSync(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.all,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func fireContacsSync(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.contacts,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func fireTeamSync(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.team,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func fireEstateSync(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.estate,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func fireEventsSync(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.events,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func fireSyncSettings(force: Bool = false) {
        let userInfo: [String: Any] = [
            Keys.syncType: SyncType.settings,
            Keys.force: force,
        ]
        NotificationCenter.default.post(name: .fireSync, object: nil, userInfo: userInfo)
    }

    static func downloadEstateImages(estateId: Int64) {
        let userInfo: [String: Any] = [
            Keys.estateId: estateId,
        ]
        NotificationCenter.default.post(name: .downloadEstateImages, object: nil, userInfo: userInfo)
    }
}
