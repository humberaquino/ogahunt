//
//  EstateSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class EstateSyncher: BaseSyncher {
    let queue: DispatchQueue
    let backend: Backend
    let estateAPI: EstateAPI
    let uploadAPI: UploadAPI

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend
        estateAPI = EstateAPI(queue: queue, backend: backend)
        uploadAPI = UploadAPI(queue: queue, backend: backend)

        super.init(syncType: .estate)
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
                // Check if events got forced so we get the latest estates too
                if !(intent.type == .events) {
                    fulfill(SyncResult.skipped(reason: result.reason!))
                    return
                }
            }

            self.estateAPI.fetchEstatesFor(teamId: team.id).then(on: self.queue) { estateListResponse in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                guard let estates = estateListResponse.estates else {
                    fulfill(SyncResult.failed(reason: "Estates not provided"))
                    return
                }
                do {
                    let newSavedEstates = try self.mergeEstates(estates: estates, context: context)
                    log.debug("New estates: \(newSavedEstates)")
                    self.markSyncWith(result: SyncResult.runned)
                    fulfill(SyncResult.runned)
                } catch {
                    self.markSyncWith(result: SyncResult.error(error: error))
                    reject(error)
                }

            }.catch { error in
                self.markSyncWith(result: SyncResult.error(error: error))
                reject(error)
            }
        }
    }

    func mergeEstates(estates: [EstateResponse], context: NSManagedObjectContext) throws -> Int {
        let estateService = EstateService(managedObjectContext: context)

        let dbEstates = estateService.allEstates() ?? []
        var dbEstateMap: [Int64: Estate] = [:]
        dbEstates.forEach { estate in
            dbEstateMap[estate.id] = estate
        }

        var saved = 0
        var merged = 0
        var errors = 0
        var lastError: Error?

        // For each user from the request, check if it exists and update
        try estates.forEach { estate in
            guard let id = estate.id else {
                return // skip
            }

            if let dbEstate = dbEstateMap[id] {
                // A DB user already exists. Skip for now
                // TODO: Compare and update based on version id
                log.debug("Estate already exists: \(dbEstate.id). Skip merge for now")

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    _ = try estateService.mergeWithExistingEstate(estateResponse: estate)

                    merged += 1
                } catch {
                    print(error)
                    errors += 1
                    lastError = error
                }

            } else {
                // Save the user
                let estate = try estateService.save(estateResponse: estate)
                log.debug("Estate saved. Id: \(estate.id)")
                saved += 1
            }
        }

        // Get all stored estates
        try estateService.deleteNonExisting(estatesResponses: estates)

        log.debug("Sync Estate. Saved \(saved)")
        log.debug("Sync Estate. Merged \(merged)")
        log.debug("Sync Estate. Errors \(errors)")
        if let lastError = lastError {
            log.error(lastError)
        }

        return saved
    }
}
