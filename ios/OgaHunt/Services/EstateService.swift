//
//  EstateService.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

class EstateService {
    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func allEstateFRC() -> NSFetchedResultsController<Estate> {
        let fetchRequest: NSFetchRequest<Estate> = Estate.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Estate.insertedAt),
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

    func allEstates() -> [Estate]? {
        let request: NSFetchRequest<Estate> = Estate.fetchRequest()

        do {
            let estates = try managedObjectContext.fetch(request)
            return estates
        } catch {
            log.error(error)
            return nil
        }
    }

    func allEstateEvents() -> [EstateEvent]? {
        let request: NSFetchRequest<EstateEvent> = EstateEvent.fetchRequest()

        do {
            let events = try managedObjectContext.fetch(request)
            return events
        } catch {
            log.error(error)
            return nil
        }
    }

    func createNewEstate() -> Estate {
        let estate = Estate(context: managedObjectContext)
        estate.createdAt = NSDate()
        estate.status = Estate.Status.Open
//        estate.hunting = true // Assume you add it to hunt right away
        return estate
    }

    func append(images: [UIImage], to estate: Estate) throws {
        let dataManager = DataManager()

        var imageList: [Image] = []

        for image in images {
            let name = String.random()

            let path = try dataManager.saveAsJPG(image: image, with: name)

            let imageModel = Image(context: managedObjectContext)
            imageModel.createdAt = NSDate()
            imageModel.localPath = path
            imageList.append(imageModel)
        }

        if let existingSet = estate.images?.mutableCopy() as? NSMutableOrderedSet {
            existingSet.addObjects(from: imageList)
            estate.images = NSOrderedSet(orderedSet: existingSet)
        } else {
            estate.images = NSOrderedSet(array: imageList)
        }
    }

    func setEstateMainContact(estate: Estate, contact: Contact) {
        estate.mainContact = contact
    }

    func update(estate: Estate, location: CLLocationCoordinate2D) {
        let locationModel = Location(context: managedObjectContext)
        locationModel.longitude = location.longitude
        locationModel.latitude = location.latitude

        estate.location = locationModel
    }

    func delete(estate: Estate) throws {
        managedObjectContext.delete(estate)
        try saveContext()
    }

    func deleteImageFrom(estate: Estate, at index: Int) throws {
        guard let image = estate.images?.object(at: index) as? Image else { return }
        let path = image.localPath

        managedObjectContext.delete(image)
        try saveContext()
        // Delete file
        if path != nil {
            let dataManager = DataManager()
            dataManager.deleteImageAt(path: path!)
        }
    }

    func toggleArchive(estate: Estate) throws {
        if let status = estate.status {
            if status == Estate.Status.Archived {
                estate.status = Estate.Status.Open
            } else {
                estate.status = Estate.Status.Archived
            }
        } else {
            estate.status = Estate.Status.Archived
        }
        try saveContext()
    }

    func setEstateStatus(estate: Estate, status: String) throws {
        if status == Estate.Status.Open {
            estate.status = Estate.Status.Open
        } else if status == Estate.Status.Archived {
            estate.status = Estate.Status.Archived
        } else {
            estate.status = Estate.Status.Unknown
        }
        try saveContext()
    }

    func setStatus(estate: Estate) throws {
        if let status = estate.status {
            if status == Estate.Status.Archived {
                estate.status = Estate.Status.Open
            } else {
                estate.status = Estate.Status.Archived
            }
        } else {
            estate.status = Estate.Status.Archived
        }
        try saveContext()
    }

    func toggleHunt(estate _: Estate) throws {
        // FIXME: Maybe this will convert to "Assign to me"
//        estate.hunting = !estate.hunting
        try saveContext()
    }

    func saveContext() throws {
        try managedObjectContext.save()
    }

    func save(estateResponse: EstateResponse) throws -> Estate {
        let newEstate = Estate(context: managedObjectContext)

        guard let id = estateResponse.id else {
            throw EstateError.noIdProvided
        }

        let now = NSDate()

        newEstate.synchedAt = now
        newEstate.id = id
        newEstate.details = estateResponse.details
        newEstate.address = estateResponse.address
        newEstate.name = estateResponse.name
        newEstate.status = estateResponse.status
        newEstate.type = estateResponse.type
        if let version = estateResponse.version {
            newEstate.version = version
        }

        if let insertedAt = estateResponse.insertedAt {
            if let date = insertedAt.parseDate() {
                newEstate.insertedAt = date as NSDate
            } else {
                log.warning("Can't parse date: \(insertedAt). Ignoring")
            }
        }

        if let updatedAt = estateResponse.updatedAt {
            if let date = updatedAt.parseDate() {
                newEstate.updatedAt = date as NSDate
            } else {
                log.warning("Can't parse date: \(updatedAt). Ignoring")
            }
        }

        newEstate.isDraft = false
        newEstate.isDirty = false

        if let userId = estateResponse.assignedToId {
            associateUserWithEstate(userId: userId, estate: newEstate)
        }

        if let mainContact = estateResponse.mainContact, let mainContactId = mainContact.id {
            // TODO: Maybe is a good oportunity to update the contact?
            associateContactWithEstate(contactId: mainContactId, estate: newEstate)
        }

        if let images = estateResponse.images {
            createAndAppendImages(imageResponses: images, estate: newEstate)
        }

        if let currentPrice = estateResponse.currentPrice {
            createAndAssociatePrice(currentPrice: currentPrice, estate: newEstate)
        }

        if let location = estateResponse.location {
            createAndAssociateLocation(locationResponse: location, estate: newEstate)
        }

        try saveContext()
        return newEstate
    }

    func save(estateEventResponse: EstateEventResponse) throws -> EstateEvent {
        let newEstateEvent = EstateEvent(context: managedObjectContext)

        guard let id = estateEventResponse.id else {
            throw EstateError.noIdProvided
        }

//        let now = NSDate()

        newEstateEvent.id = id
        newEstateEvent.change = estateEventResponse.change
        newEstateEvent.changeType = estateEventResponse.changeType
        if let date = estateEventResponse.insertedAt?.parseDate() {
            newEstateEvent.insertedAt = date as NSDate
        }

        if let insertedAt = estateEventResponse.insertedAt {
            if let date = insertedAt.parseDate() {
                newEstateEvent.insertedAt = date as NSDate
            } else {
                log.warning("Can't parse date: \(insertedAt). Ignoring")
            }
        }

        if let estateId = estateEventResponse.estateId {
            if let estate = findBy(id: estateId) {
                newEstateEvent.estate = estate
            } else {
                // TODO: Mark the estate as erroneous
                print("No estate with id \(estateId) found locally")
            }
        }

        if let userId = estateEventResponse.byUserId {
            let userService = UserService(managedObjectContext: managedObjectContext)
            if let user = userService.findBy(id: userId) {
                newEstateEvent.byUser = user
            } else {
                // TODO: Mark the estate as erroneous
                print("No user with id \(userId) found locally")
            }
        }

        try saveContext()
        return newEstateEvent
    }

    func createAndAssociateLocation(locationResponse: LocationResponse, estate: Estate) {
        let location = Location(context: managedObjectContext)

        location.longitude = locationResponse.longitude ?? 0
        location.latitude = locationResponse.latitude ?? 0
        location.id = locationResponse.id ?? -1

        estate.location = location
    }

    func createAndAssociatePrice(currentPrice: PriceResponse, estate: Estate) {
        let price = createNewPrice(priceResponse: currentPrice)

        // Associate to estate
        estate.currentPrice = price
        price.estate = estate
    }

    func createNewPrice(priceResponse: PriceResponse) -> Price {
        let price = Price(context: managedObjectContext)

        price.id = priceResponse.id ?? -1
        if let amount = priceResponse.amount {
            if let decimal = Decimal(string: amount) {
                price.amount = NSDecimalNumber(decimal: decimal)
            } else {
                log.warning("Got a value as decimal but is not parsable: \(amount)")
            }
        }

        if let insertedAt = priceResponse.insertedAt {
            if let date = insertedAt.parseDate() {
                price.insertedAt = date as NSDate
            } else {
                log.warning("Can't parse date: \(insertedAt). Ignoring")
            }
        }

        return price
    }

    func createAndAppendImages(imageResponses: [ImageResponse], estate: Estate) {
        if imageResponses.isEmpty {
            return
        }

        imageResponses.forEach { imageResponse in
            // Create an image
            let image = Image(context: managedObjectContext)
            image.merge(imageResponse: imageResponse)
            // Associate to estate
            estate.addToImages(image)
        }
    }

//
//    func createNewImage(imageResponse: ImageResponse) -> Image {
//
//
//    }

    func associateUserWithEstate(userId: Int64, estate: Estate) {
        // Find user
        let userService = UserService(managedObjectContext: managedObjectContext)
        if let user = userService.findBy(id: userId) {
            estate.assignedTo = user
        } else {
            log.warning("No user found with id: \(userId). Skipping")
        }
    }

    func associateContactWithEstate(contactId: Int64, estate: Estate) {
        let contactService = ContactService(managedObjectContext: managedObjectContext)
        if let contact = contactService.findBy(id: contactId) {
            estate.mainContact = contact
        } else {
            log.warning("No contact found with id: \(contactId). Skipping")
        }
    }

    func findBy(id estateId: Int64) -> Estate? {
        let predicate = NSPredicate(format: "id == %lld", estateId)
        let request: NSFetchRequest<Estate> = Estate.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate

        let estates = try! managedObjectContext.fetch(request)

        return estates.first
    }

    func findEstateEventBy(id estateId: Int64) -> EstateEvent? {
        let predicate = NSPredicate(format: "id == %lld", estateId)
        let request: NSFetchRequest<EstateEvent> = EstateEvent.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate

        let events = try! managedObjectContext.fetch(request)

        return events.first
    }

    func updateImage(image: Image, uploadResult: UploadImageResult) throws {
        image.imageURL = uploadResult.resourceName
        try saveContext()
    }

    func mergeWithExistingEstate(estateResponse: EstateResponse) throws -> Estate {
        guard let id = estateResponse.id else {
            throw EstateError.noIdProvided
        }

        var estate: Estate! = findBy(id: id)
        if estate == nil {
            // no estate in db yet. Save it
            estate = Estate(context: managedObjectContext)
        }

        // Merge data too
        try estate.merge(estateResponse: estateResponse)

        try saveContext()

        return estate
    }

    func mergeWithExistingEstateEvent(estateEventResponse: EstateEventResponse) throws -> EstateEvent {
        guard let id = estateEventResponse.id else {
            throw EstateError.noIdProvided
        }

        var estateEvent: EstateEvent! = findEstateEventBy(id: id)
        if estateEvent == nil {
            // no estate in db yet. Save it
            estateEvent = EstateEvent(context: managedObjectContext)
        }

        // Merge data too
        try estateEvent.merge(estateEventResponse: estateEventResponse)

        try saveContext()

        return estateEvent
    }

    func deleteNonExisting(estatesResponses: [EstateResponse]) throws {
        // Get all estates not in the list

        var idList: [Int64] = []
        estatesResponses.forEach { estateResponse in
            if let id = estateResponse.id {
                idList.append(id)
            }
        }

//        let fetchRequest: NSFetchRequest<Estate> = Estate.fetchRequest()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Estate")
        fetchRequest.predicate = NSPredicate(format: "NOT (id IN %@)", idList)

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        batchDeleteRequest.resultType = .resultTypeCount

//        let persistentStoreCoordinator = context.persistentStoreCoordinator!
//
//        do {
//            try persistentStoreCoordinator.execute(deleteRequest, with: context)
//        } catch let error as NSError {
//            debugPrint(error)
//        }

        // Execute Batch Request
        let batchDeleteResult = try managedObjectContext.execute(batchDeleteRequest) as! NSBatchDeleteResult

        log.debug("The batch delete request has deleted \(batchDeleteResult.result!) records.")

        // Reset Managed Object Context
//        managedObjectContext.reset()
    }
}

enum EstateError: Error {
    case noIdProvided
    case notFound
    case nonImageSaved
}
