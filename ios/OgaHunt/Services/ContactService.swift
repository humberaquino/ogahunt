//
//  ContactService.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation

class ContactService {
    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func allEstateFRC() -> NSFetchedResultsController<Estate> {
        let fetchRequest: NSFetchRequest<Estate> = Estate.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Estate.createdAt),
                                    ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchedResultsController
    }

    func createNewEstate() -> Estate {
        let estate = Estate(context: managedObjectContext)
        estate.createdAt = NSDate()
        estate.status = Estate.Status.Open
//        estate.hunting = true // Assume you add it to hunt right away
        return estate
    }

    func allContacts() -> [Contact]? {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()

        do {
            let contact = try managedObjectContext.fetch(request)
            return contact
        } catch {
            log.error(error)
            return nil
        }
    }

    func save(contactResponse: ContactResponse) throws -> Contact {
        let newContact = Contact(context: managedObjectContext)

        try merge(contact: newContact, contactResponse: contactResponse)

        try managedObjectContext.save()
        return newContact
    }

    func merge(contact: Contact, contactResponse: ContactResponse) throws {
        guard let id = contactResponse.id else {
            throw ContactError.noIdProvided
        }

        contact.id = id
        contact.details = contactResponse.details
        contact.firstName = contactResponse.firstName
        contact.lastName = contactResponse.lastName
        contact.phone1 = contactResponse.phone1
        contact.phone2 = contactResponse.phone2
        contact.version = contactResponse.version ?? -1
        contact.teamId = contactResponse.teamId ?? -1
    }

    func findBy(id userId: Int64) -> Contact? {
        let predicate = NSPredicate(format: "id == %lld", userId)
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate

        let contacts = try! managedObjectContext.fetch(request)

        return contacts.first
    }

    func delete(contact: Contact) throws {
        managedObjectContext.delete(contact)
        try managedObjectContext.save()
    }

    func deleteNonExisting(contactsResponses: [ContactResponse]) throws {
        // Get all estates not in the list

        var idList: [Int64] = []
        contactsResponses.forEach { contactsResponse in
            if let id = contactsResponse.id {
                idList.append(id)
            }
        }

        //        let fetchRequest: NSFetchRequest<Estate> = Estate.fetchRequest()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "NOT (id IN %@)", idList)

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        batchDeleteRequest.resultType = .resultTypeCount

        // Execute Batch Request
        let batchDeleteResult = try managedObjectContext.execute(batchDeleteRequest) as! NSBatchDeleteResult

        log.debug("The batch delete request has deleted \(batchDeleteResult.result!) contact records.")
    }
}

enum ContactError: Error {
    case noIdProvided
}
