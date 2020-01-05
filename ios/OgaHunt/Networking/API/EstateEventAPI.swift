//
//  EstateEventAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class EstateEventAPI {
    let backend: Backend
    let queue: DispatchQueue

    init(queue: DispatchQueue, backend: Backend) {
        self.backend = backend
        self.queue = queue
    }

    init(backend: Backend) {
        self.backend = backend
        queue = .main
    }

    func fetchEstateEvents(teamId: Int64) -> Promise<EstateEventListResponse> {
        return Promise<EstateEventListResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(ContactsAPIError.noAuthValue)
                return
            }

            let teamEventsURL = self.backend.teamEstateEventsURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(teamEventsURL, method: .get, encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in

                if response.result.isFailure {
                    print("\(response.result.debugDescription)")

                    let reason = response.result.error?.detailedReason ?? "Unknown error"
                    reject(APIError.failedRequest(cause: reason))
                    return
                }

                guard let value = response.result.value else {
                    reject(APIError.invalidResponseValue)
                    return
                }

                if response.response?.statusCode != 200 {
                    reject(APIError.invalidRequest(cause: value))
                    return
                }

                guard let response = Mapper<EstateEventListResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(response)
            }
        }
    }
}
