//
//  ContactSyncAction.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class ContactSyncAction {
    let queue: DispatchQueue
    let backend: Backend
    let contactAPI: ContactAPI
    let contactService: ContactService
    //    let context: NSManagedObjectContext

    init(queue: DispatchQueue, backend: Backend, context: NSManagedObjectContext) {
        self.queue = queue
        self.backend = backend
        contactService = ContactService(managedObjectContext: context)
        contactAPI = ContactAPI(queue: queue, backend: backend)
    }

    func deleteContactRemotelly(contact: Contact) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            let contactId = contact.id
            self.contactAPI.deleteContact(teamId: team.id, contactId: contactId).then { result in

                if result.success == true {
                    do {
                        try self.contactService.delete(contact: contact)
                        fulfill(OPResult(success: true, reason: nil))

                    } catch {
                        print(error)
                        reject(error)
                    }

                } else {
                    fulfill(OPResult(success: false, reason: result.message))
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }
}
