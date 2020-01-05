//
//  ContactsAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class ContactAPI {
    let backend: Backend
    let queue: DispatchQueue

    init(backend: Backend) {
        self.backend = backend
        queue = .main
    }

    init(queue: DispatchQueue, backend: Backend) {
        self.backend = backend
        self.queue = queue
    }

    func fetchTeamContacts(teamId: Int64) -> Promise<ContactListResponse> {
        return Promise<ContactListResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let teamContactsURL = self.backend.teamContactListURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(teamContactsURL, method: .get, encoding: JSONEncoding.default,
                              headers: headers).responseString(queue: self.queue) { response in

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

                guard let contactListResponse = Mapper<ContactListResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(contactListResponse)
            }
        }
    }

    func updateContact(teamId: Int64, contactResponse: ContactResponse) -> Promise<ContactResponse> {
        return Promise<ContactResponse> { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            guard let contactId = contactResponse.id else {
                reject(ContactsAPIError.noIdProvided)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let jsonBody = contactResponse.toJSON()
            let parameters: [String: Any] = [
                "contact": jsonBody,
            ]

            let url = self.backend.teamContactUpdateURL(teamId: teamId, contactId: contactId)
            Alamofire.request(url, method: .post, parameters: parameters,
                              encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in
                print("Request: \(String(describing: response.request))") // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)") // response serialization result

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

                guard let code = response.response?.statusCode else {
                    reject(APIError.noResponseCode)
                    return
                }

                if code == 400 {
                    reject(APIError.invalidRequest(cause: value))
                    return
                }

                if code != 200 {
                    reject(APIError.errorRequest(code: code, cause: value))
                    return
                }

                guard let contactSingleResponse = Mapper<ContactSingleResponse>().map(JSONString: value),
                    let contactReponse = contactSingleResponse.contact else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(contactReponse)
            }
        }
    }

    func saveContact(teamId: Int64, contactResponse: ContactResponse) -> Promise<ContactResponse> {
        return Promise<ContactResponse> { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let jsonBody = contactResponse.toJSON()
            let parameters: [String: Any] = [
                "contact": jsonBody,
            ]

            let url = self.backend.teamContactCreateURL(teamId: teamId)
            Alamofire.request(url, method: .post, parameters: parameters,
                              encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in
                print("Request: \(String(describing: response.request))") // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)") // response serialization result

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

                guard let code = response.response?.statusCode else {
                    reject(APIError.noResponseCode)
                    return
                }

                if code == 400 {
                    reject(APIError.invalidRequest(cause: value))
                    return
                }

                if code != 201 {
                    reject(APIError.errorRequest(code: code, cause: value))
                    return
                }

                guard let contactSingleResponse = Mapper<ContactSingleResponse>().map(JSONString: value),
                    let contactReponse = contactSingleResponse.contact else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(contactReponse)
            }
        }
    }

    func deleteContact(teamId: Int64, contactId: Int64) -> Promise<ResultResponse> {
        return Promise<ResultResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let deleteContactURL = self.backend.teamContactDeleteURL(teamId: teamId, contactId: contactId)
            Alamofire.request(deleteContactURL, method: .delete,
                              encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in
                print("Request: \(String(describing: response.request))") // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)") // response serialization result

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

                guard let code = response.response?.statusCode else {
                    reject(APIError.noResponseCode)
                    return
                }

                if code == 400 {
                    reject(APIError.invalidRequest(cause: value))
                    return
                }

                if code != 200 {
                    reject(APIError.errorRequest(code: code, cause: value))
                    return
                }

                guard let resultResponse = Mapper<ResultResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(resultResponse)
            }
        }
    }
}

enum ContactsAPIError: Error {
    case noTeamSelected
    case noAuthValue
    case noIdProvided
}
