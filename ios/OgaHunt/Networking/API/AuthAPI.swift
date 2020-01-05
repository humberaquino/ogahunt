//
//  AuthAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/24/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

class AuthAPI {
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

    func signin(email: String, password: String) -> Promise<AuthResponse> {
        return Promise<AuthResponse> { fulfill, reject in

            let loginURL = self.backend.loginURL()

            let parameters: Parameters = [
                "email": email,
                "password": password,
            ]

            Alamofire.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString(queue: self.queue) { response in
                print("Request: \(String(describing: response.request))") // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)") // response serialization result

                if response.result.isFailure {
                    print("\(response.result.debugDescription)")

                    let reason = response.result.error?.detailedReason ?? "Unknown error"
                    reject(SigninError.failedRequest(cause: reason))
                    return
                }

                guard let value = response.result.value else {
                    reject(SigninError.invalidResponseValue)
                    return
                }

                if response.response?.statusCode != 200 {
                    reject(SigninError.invalidRequest(cause: value))
                    return
                }

                guard let auth = Mapper<AuthResponse>().map(JSONString: value) else {
                    reject(SigninError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(auth)
            }
        }
    }

    func register(registration: RegisterRequest) -> Promise<ResultResponse> {
        return Promise<ResultResponse> { fulfill, reject in

            let registerURL = self.backend.registerURL()

            let parameters = registration.toJSON()

            Alamofire.request(registerURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString(queue: self.queue) { response in
                print("Request: \(String(describing: response.request))") // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)") // response serialization result

                if response.result.isFailure {
                    print("\(response.result.debugDescription)")

                    let reason = response.result.error?.detailedReason ?? "Unknown error"
                    reject(SigninError.failedRequest(cause: reason))
                    return
                }

                guard let value = response.result.value else {
                    reject(SigninError.invalidResponseValue)
                    return
                }

                if response.response?.statusCode != 200 {
                    reject(SigninError.invalidRequest(cause: value))
                    return
                }

                guard let result = Mapper<ResultResponse>().map(JSONString: value) else {
                    reject(SigninError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(result)
            }
        }
    }
}

enum SigninError: Error {
    case failedRequest(cause: String)
    case invalidRequest(cause: String)
    case invalidResponseValue
    case invalidJSON(responseBody: String)
}
