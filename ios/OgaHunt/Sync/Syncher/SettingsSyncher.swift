//
//  SettingsSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class SettingsSyncher: BaseSyncher {
    let queue: DispatchQueue
    let backend: Backend
    let settingsAPI: SettingsAPI

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend
        settingsAPI = SettingsAPI(queue: queue, backend: backend)
        super.init(syncType: .settings)
    }

    func sync(intent: SyncIntent) -> Promise<SyncResult> {
        return Promise<SyncResult>(on: queue) { fulfill, reject in

            let result = self.shouldRun(intent: intent)
            if !result.yes {
                fulfill(SyncResult.skipped(reason: result.reason!))
                return
            }

            self.settingsAPI.fetchSettings().then(on: self.queue) { settingsResponse in
                try self.mergeSettings(settings: settingsResponse)
                self.markSyncWith(result: SyncResult.runned)
                fulfill(SyncResult.runned)
            }.catch { error in
                self.markSyncWith(result: SyncResult.error(error: error))
                reject(error)
            }
        }
    }

    private func mergeSettings(settings: SettingsResponse) throws {
        let settingService = SettingsService()

        try settingService.saveSettings(settingsResponse: settings)
    }
}
