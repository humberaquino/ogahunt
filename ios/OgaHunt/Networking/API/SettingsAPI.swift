//
//  SettingsAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class SettingsAPI {
    let backend: Backend
    let queue: DispatchQueue

    init(queue: DispatchQueue, backend: Backend) {
        self.backend = backend
        self.queue = queue
    }

    func fetchSettings() -> Promise<SettingsResponse> {
        return Promise<SettingsResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(ContactsAPIError.noAuthValue)
                return
            }

            let settingsURL = self.backend.settingsURL()

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(settingsURL, method: .get, encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in

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

                guard let settingsResponse = Mapper<SettingsResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(settingsResponse)
            }
        }
    }
}

enum SettingsAPIError: Error {
    case noAuthValue
}
