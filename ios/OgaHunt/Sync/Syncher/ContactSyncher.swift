//
//  ContactSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class ContactSyncher: BaseSyncher {
    let queue: DispatchQueue
    let backend: Backend
    let contactAPI: ContactAPI
//    let context: NSManagedObjectContext

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend
//        self.context = context
        contactAPI = ContactAPI(queue: queue, backend: backend)
        super.init(syncType: .contacts)
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

            self.contactAPI.fetchTeamContacts(teamId: team.id).then(on: self.queue) { contactListResponse in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                guard let contacts = contactListResponse.contacts else {
                    fulfill(SyncResult.failed(reason: "Contacts not provided"))
                    return
                }
                do {
                    let newSavedCount = try self.mergeContacts(contacts: contacts, context: context)
                    log.debug("New contacts: \(newSavedCount)")
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

    func mergeContacts(contacts: [ContactResponse], context: NSManagedObjectContext) throws -> Int {
        let contactService = ContactService(managedObjectContext: context)
        let dbContacts = contactService.allContacts() ?? []
        var dbContactsMap: [Int64: Contact] = [:]
        dbContacts.forEach { contact in
            dbContactsMap[contact.id] = contact
        }

        var saved = 0
        // For each user from the request, check if it exists and update
        try contacts.forEach { contact in
            guard let id = contact.id else {
                return // skip
            }

            if let dbContact = dbContactsMap[id] {
                // A DB user already exists. Skip for now
                log.debug("Contact already exists: \(dbContact.id). Skip merge for now")
            } else {
                // Save the user
                let contact = try contactService.save(contactResponse: contact)
                log.debug("Contact saved. Id: \(contact.id)")
                saved += 1
            }
        }

        try contactService.deleteNonExisting(contactsResponses: contacts)

        return saved
    }
}
