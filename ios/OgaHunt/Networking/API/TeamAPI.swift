//
//  TeamAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class TeamAPI {
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

    func fetchTeamUsers(teamId: Int64) -> Promise<TeamUsersResponse> {
        return Promise<TeamUsersResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(ContactsAPIError.noAuthValue)
                return
            }

            let teamUsersURL = self.backend.teamUsersURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(teamUsersURL, method: .get, encoding: JSONEncoding.default, headers: headers).responseString(queue: self.queue) { response in

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

                guard let teamUsersResponse = Mapper<TeamUsersResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(teamUsersResponse)
            }
        }
    }

    func fetchUserInvitations(teamId: Int64) -> Promise<UserInviteListResponse> {
        return Promise<UserInviteListResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(ContactsAPIError.noAuthValue)
                return
            }

            let teamUsersInvitationsURL = self.backend.teamUserInvitationsURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(teamUsersInvitationsURL,
                              method: .get,
                              encoding: JSONEncoding.default,
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

                guard let invitationResponse = Mapper<UserInviteListResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(invitationResponse)
            }
        }
    }

    func sendUserInvitation(teamId: Int64, email: String) -> Promise<ResultResponse> {
        return Promise<ResultResponse>(on: queue) { fulfill, reject in

            guard let authValue = self.backend.basicAuthValue() else {
                reject(ContactsAPIError.noAuthValue)
                return
            }

            let teamUserInvitateURL = self.backend.teamUserInvitateURL(teamId: teamId)

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "email": email,
            ]

            Alamofire.request(teamUserInvitateURL,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
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

                guard let invitationResponse = Mapper<ResultResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(invitationResponse)
            }
        }
    }
}

enum TeamAPIError: Error {
    case noAuthValue
}
