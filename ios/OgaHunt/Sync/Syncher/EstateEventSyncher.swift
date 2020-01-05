//
//  EstateEventSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class EstateEventSyncher: BaseSyncher {
    let queue: DispatchQueue
    private let backend: Backend
    private let estateEventAPI: EstateEventAPI

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend
        estateEventAPI = EstateEventAPI(queue: queue, backend: backend)

        super.init(syncType: .events)
    }

    func sync(intent: SyncIntent, context: NSManagedObjectContext) -> Promise<SyncResult> {
        return Promise<SyncResult>(on: queue) { fulfill, reject in

            // 1. Fetch all contacts, map them
            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            let result = self.shouldRun(intent: intent)
            if !result.yes {
                fulfill(SyncResult.skipped(reason: result.reason!))
                return
            }

            self.estateEventAPI.fetchEstateEvents(teamId: team.id).then(on: self.queue) { teamEventsResponse in
                do {
                    guard let responseEvents = teamEventsResponse.events else {
                        fulfill(SyncResult.failed(reason: "events not provided"))
                        return
                    }

                    let usersSaved = try self.mergeTeamEvents(events: responseEvents, context: context)
                    log.debug("New events: \(usersSaved)")
                    self.markSyncWith(result: SyncResult.runned)
                    fulfill(SyncResult.runned)
                } catch {
                    self.markSyncWith(result: SyncResult.error(error: error))
                    reject(error)
                }
            }
        }
    }

    func mergeTeamEvents(events: [EstateEventResponse], context: NSManagedObjectContext) throws -> Int {
        // Get users from the DB
        let estateService = EstateService(managedObjectContext: context)

        let dbEvents = estateService.allEstateEvents() ?? []
        var dbEventsMap: [Int64: EstateEvent] = [:]
        dbEvents.forEach { event in
            dbEventsMap[event.id] = event
        }

        var saved = 0
        var merged = 0
        var errors = 0
        var lastError: Error?

        // For each user from the request, check if it exists and update
        try events.forEach { event in
            guard let id = event.id else {
                return // skip
            }

            if let dbEvent = dbEventsMap[id] {
                // A DB user already exists. Skip for now
                // TODO: Compare and update based on version id
                log.debug("Estate event already exists: \(dbEvent.id). Skip merge for now")

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    _ = try estateService.mergeWithExistingEstateEvent(estateEventResponse: event)
                    merged += 1
                } catch {
                    print(error)
                    errors += 1
                    lastError = error
                }

            } else {
                // Save the user
                let savedEvent = try estateService.save(estateEventResponse: event)
                log.debug("Estate event saved. Id: \(savedEvent.id)")
                saved += 1
            }
        }

        // TODO: Delete non existing events
        // Get all stored estates
//        try estateService.deleteNonExisting(estatesResponses: estates)

        log.debug("Sync Events. Saved \(saved)")
        log.debug("Sync Events. Merged \(merged)")
        log.debug("Sync Events. Errors \(errors)")
        if let lastError = lastError {
            log.error(lastError)
        }

        return saved
    }
}
