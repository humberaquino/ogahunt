//
//  EstateEventTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Foundation
import ObjectMapper

extension EstateEvent {
    func merge(estateEventResponse: EstateEventResponse) throws {
        guard let estateEventResponseId = estateEventResponse.id else {
            throw EstateTransformError.noIdInResponse
        }

        id = estateEventResponseId
        change = estateEventResponse.change
        changeType = estateEventResponse.changeType
        if let date = estateEventResponse.insertedAt?.parseDate() {
            insertedAt = date as NSDate
        }

        if let estateId = estateEventResponse.estateId {
            let estateService = EstateService(managedObjectContext: managedObjectContext!)
            if let estate = estateService.findBy(id: estateId) {
                self.estate = estate
            } else {
                // TODO: Mark the estate as erroneous
                print("No estate with id \(estateId) found locally")
            }
        }

        if let userId = estateEventResponse.byUserId {
            let userService = UserService(managedObjectContext: managedObjectContext!)
            if let user = userService.findBy(id: userId) {
                byUser = user
            } else {
                // TODO: Mark the estate as erroneous
                print("No user with id \(userId) found locally")
            }
        }
    }
}

//
// extension EstateResponse {
//    func updateWith(coordinate: CLLocationCoordinate2D) {
//        let location = LocationResponse(JSONString: "{}")!
//        location.latitude = coordinate.latitude
//        location.longitude = coordinate.longitude
//        self.location = location
//    }
//
//    static func buildEmpty() -> EstateResponse? {
//        return EstateResponse(JSONString: "{}")
//    }
// }
//
// enum EstateTransformError: Error {
//    case noIdInResponse
//    case noContactId
// }
