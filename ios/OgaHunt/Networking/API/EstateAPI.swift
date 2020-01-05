//
//  EstateAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class EstateAPI {
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

    func fetchEstatesFor(teamId: Int64) -> Promise<EstateListResponse> {
        return Promise<EstateListResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let teamEstateURL = self.backend.teamEstateListURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(teamEstateURL, method: .get, encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in

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

                guard let estateListResponse = Mapper<EstateListResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(estateListResponse)
            }
        }
    }

    func createEstate(teamId: Int64, estateResponse: EstateResponse) -> Promise<EstateResponse> {
        return Promise<EstateResponse>(on: queue) { fulfill, reject in

            let jsonBody = estateResponse.toJSON()

            let createEstateURL = self.backend.teamEstateCreateURL(teamId: teamId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "estate": jsonBody,
            ]

            print(parameters)

            Alamofire.request(createEstateURL, method: .post, parameters: parameters,
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

                guard let updatedEstateSingleResponse = Mapper<EstateSingleResponse>().map(JSONString: value),
                    let estateResponse = updatedEstateSingleResponse.estate else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(estateResponse)
            }
        }
    }

    func updateEstate(teamId: Int64, estateResponse: EstateResponse) -> Promise<EstateResponse> {
        return Promise<EstateResponse>(on: queue) { fulfill, reject in

            guard let estateId = estateResponse.id else {
                reject(EstateAPIError.noEstateIdProvided)
                return
            }

            let jsonBody = estateResponse.toJSON()

            let updateEstateURL = self.backend.teamEstateUpdateURL(teamId: teamId, estateId: estateId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "estate": jsonBody,
            ]

            print(parameters)

            Alamofire.request(updateEstateURL, method: .post, parameters: parameters,
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

                guard let updatedEstateSingleResponse = Mapper<EstateSingleResponse>().map(JSONString: value),
                    let estateResponse = updatedEstateSingleResponse.estate else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(estateResponse)
            }
        }
    }

    func deleteEstate(teamId: Int64, estateResponse: EstateResponse) -> Promise<ResultResponse> {
        return Promise<ResultResponse>(on: queue) { fulfill, reject in

            guard let estateId = estateResponse.id else {
                reject(EstateAPIError.noEstateIdProvided)
                return
            }

            let updateEstateURL = self.backend.teamEstateUpdateURL(teamId: teamId, estateId: estateId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(updateEstateURL, method: .delete,
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

    func updateLocation(teamId: Int64, estateId: Int64, locationResponse: LocationResponse) -> Promise<EstateResponse> {
        return Promise<EstateResponse>(on: queue) { fulfill, reject in

            let jsonBody = locationResponse.toJSON()

            let updateEstateURL = self.backend.teamEstateUpdateLocationURL(teamId: teamId, estateId: estateId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "estate": [
                    "location": jsonBody,
                ],
            ]

            print(parameters)

            Alamofire.request(updateEstateURL, method: .post, parameters: parameters,
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

                guard let updatedEstateSingleResponse = Mapper<EstateSingleResponse>().map(JSONString: value),
                    let estateResponse = updatedEstateSingleResponse.estate else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(estateResponse)
            }
        }
    }

    func assignEstate(teamId: Int64, estateId: Int64, userId: Int64?) -> Promise<ResultResponse> {
        return Promise<ResultResponse>(on: queue) { fulfill, reject in

            let assignEstateURL = self.backend.teamEstateAssignURL(teamId: teamId, estateId: estateId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            var parameters: [String: Any] = [:]
            if let userId = userId {
                parameters["assign_to"] = userId
            }

            Alamofire.request(assignEstateURL, method: .post, parameters: parameters,
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

    func updateStatus(teamId: Int64, estateId: Int64, status: String) -> Promise<ResultResponse> {
        return Promise<ResultResponse>(on: queue) { fulfill, reject in

            let updateEstateURL = self.backend.teamEstateUpdateStatusURL(teamId: teamId, estateId: estateId)

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "status": status,
            ]

            Alamofire.request(updateEstateURL, method: .post, parameters: parameters,
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

enum EstateAPIError: Error {
    case noEstateIdProvided
}
