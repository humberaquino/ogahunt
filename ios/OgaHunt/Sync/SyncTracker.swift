//
//  SyncTracker.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

struct Result {
    let yes: Bool
    var reason: String?
}

class SyncTracker {
    let queue: DispatchQueue
    let backend: Backend

    let teamSyncher: TeamSyncher
    let contactSyncher: ContactSyncher
    let estateSyncher: EstateSyncher
    let estateEventSyncher: EstateEventSyncher
    let settingsSyncher: SettingsSyncher

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend

        teamSyncher = TeamSyncher(queue: self.queue, backend: self.backend)
        contactSyncher = ContactSyncher(queue: self.queue, backend: self.backend)
        estateSyncher = EstateSyncher(queue: self.queue, backend: self.backend)
        estateEventSyncher = EstateEventSyncher(queue: self.queue, backend: self.backend)
        settingsSyncher = SettingsSyncher(queue: self.queue, backend: self.backend)

        // Config
        teamSyncher.resyncThreaholdSecs = 15 * 60 // 15 min
        contactSyncher.resyncThreaholdSecs = 5 * 60 // 5 min
        estateSyncher.resyncThreaholdSecs = 5 * 60 // 5 min
        estateEventSyncher.resyncThreaholdSecs = 5 * 60 // 5 min
        settingsSyncher.resyncThreaholdSecs = 15 * 60 // 15 min
    }

    func processSync(intent: SyncIntent, context: NSManagedObjectContext) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fullfil, reject in

            log.debug("Processing intent \(intent)")

            // The structure is the same and always run, but each of them simply ignores if they don't have to
            // 1. settings, team, contacts can run first and in parallel
            // 2. estate
            // 3. estate events

            all(
                self.settingsSyncher.sync(intent: intent),
                self.teamSyncher.sync(intent: intent, context: context),
                self.contactSyncher.sync(intent: intent, context: context)
            ).then(on: self.queue) { settingsResult, teamResult, contactResult in

                self.estateSyncher.sync(intent: intent, context: context).then(on: self.queue) { estateResult in
                    self.estateEventSyncher.sync(intent: intent, context: context).then(on: self.queue) { eventResult in
                        log.debug("Settings: \(settingsResult)")
                        log.debug("Team \(teamResult)")
                        log.debug("Contact \(contactResult)")
                        log.debug("Estate \(estateResult)")
                        log.debug("Event: \(eventResult)")
                        fullfil(OPResult(success: true, reason: nil))
                    }.catch { error in
                        reject(error)
                    }
                }.catch { error in
                    reject(error)
                }
            }.catch { error in
                reject(error)
            }
        }
    }
}
