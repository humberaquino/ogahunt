//
//  EstateTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/31/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Foundation
import ObjectMapper

extension Estate {
    func toEstateResponse() -> EstateResponse {
        let estateResponse = Mapper<EstateResponse>().map(JSONString: "{}")!

        if id >= 0 {
            estateResponse.id = id
        }

        // Basic attrs
        estateResponse.address = address
        estateResponse.details = details
        estateResponse.name = name
        estateResponse.status = status
        estateResponse.type = type

        // Associations
        estateResponse.currentPrice = currentPriceResponse()
        estateResponse.location = currentLocationResponse()
        estateResponse.mainContact = currentMainContactResponse()

        return estateResponse
    }

    func currentPriceResponse() -> PriceResponse? {
        guard let priceResponse = Mapper<PriceResponse>().map(JSONString: "{}") else {
            return nil
        }

        priceResponse.amount = currentPrice?.amount?.stringValue
        priceResponse.currency = "USD" // TODO: Get it from the UI / settings

        return priceResponse
    }

    func currentLocationResponse() -> LocationResponse? {
        guard let locationResponse = Mapper<LocationResponse>().map(JSONString: "{}") else {
            return nil
        }

        locationResponse.latitude = location?.latitude
        locationResponse.longitude = location?.longitude

        return locationResponse
    }

    func currentMainContactResponse() -> ContactResponse? {
        guard let mainContactResponse = Mapper<ContactResponse>().map(JSONString: "{}") else {
            return nil
        }

        mainContactResponse.id = mainContact?.id

        mainContactResponse.version = mainContact?.version
        mainContactResponse.firstName = mainContact?.firstName
        mainContactResponse.lastName = mainContact?.lastName
        mainContactResponse.phone1 = mainContact?.phone1
        mainContactResponse.phone2 = mainContact?.phone2
        mainContactResponse.details = mainContact?.details

        return mainContactResponse
    }

    func merge(estateResponse: EstateResponse) throws {
        guard let estateResponseId = estateResponse.id else {
            throw EstateTransformError.noIdInResponse
        }

        id = estateResponseId
        name = estateResponse.name
        address = estateResponse.address
        details = estateResponse.details
        type = estateResponse.type
        status = estateResponse.status

        if let currentPrice = estateResponse.currentPrice {
            let price = Price(context: managedObjectContext!)
            price.merge(priceResponse: currentPrice)
            self.currentPrice = price
            prices?.adding(price)
        }

        if let locationResponse = estateResponse.location {
            let location = Location(context: managedObjectContext!)
            location.merge(locationResponse: locationResponse)
            self.location = location
        }

        if let mainContact = estateResponse.mainContact {
            let contactService = ContactService(managedObjectContext: managedObjectContext!)
            guard let contactId = mainContact.id else {
                throw EstateTransformError.noContactId
            }

            if let contact = contactService.findBy(id: contactId) {
                self.mainContact = contact
            } else {
                // Create contact. WE have all the info here
                let contact = Contact(context: managedObjectContext!)
                contact.merge(contactResponse: mainContact)
                self.mainContact = contact
            }
        }

        mergeImages(estateResponse)

        if let version = estateResponse.version {
            self.version = version
        }

        if let date = estateResponse.insertedAt?.parseDate() {
            insertedAt = date as NSDate
        }

        if let date = estateResponse.updatedAt?.parseDate() {
            updatedAt = date as NSDate
        }

        if let userId = estateResponse.assignedToId {
            let userService = UserService(managedObjectContext: managedObjectContext!)
            if let user = userService.findBy(id: userId) {
                assignedTo = user
            } else {
                // TODO: Mark the estate as erroneous
                print("No user with id \(userId) found locally")
            }
        }
    }

    fileprivate func mergeImages(_ estateResponse: EstateResponse) {
        if let responseImages = estateResponse.images {
            if let entityImages = self.images?.array as? [Image], !entityImages.isEmpty {
                // Entity has images
                responseImages.forEach { imageResponse in
                    guard let imageId = imageResponse.id else {
                        log.error("No id in response image. Skip")
                        return // skip
                    }

                    var foundImage: Image?
                    for entityImage in entityImages {
                        if entityImage.id > 0 && entityImage.id == imageId {
                            foundImage = entityImage
                            break
                        } else {
                            if let entityImageURL = entityImage.imageURL,
                                let responseIamgeURL = imageResponse.imageURL,
                                entityImageURL == responseIamgeURL {
                                foundImage = entityImage
                            }
                        }
                    }

                    if let foundImage = foundImage {
                        // merge
                        foundImage.merge(imageResponse: imageResponse)
                    } else {
                        // Add
                        let image = Image(context: self.managedObjectContext!)
                        image.merge(imageResponse: imageResponse)
                        image.estate = self
                        self.addToImages(image)
                    }
                }

            } else {
                // Entity doesn't have images
                responseImages.forEach { imageResponse in
                    let image = Image(context: self.managedObjectContext!)
                    image.merge(imageResponse: imageResponse)
                    self.addToImages(image)
                }
            }
        }
    }
}

extension EstateResponse {
    func updateWith(coordinate: CLLocationCoordinate2D) {
        let location = LocationResponse(JSONString: "{}")!
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        self.location = location
    }

    static func buildEmpty() -> EstateResponse? {
        return EstateResponse(JSONString: "{}")
    }
}

enum EstateTransformError: Error {
    case noIdInResponse
    case noContactId
}
