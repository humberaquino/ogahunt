//
//  DownloadAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/3/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

struct DownloadResult {
    var data: Data?
    var error: Error?
    var reason: String?
}

class DownloadAPI {
    let backend: Backend
    let queue: DispatchQueue

    init(queue: DispatchQueue, backend: Backend) {
        self.backend = backend
        self.queue = queue
    }

    func downloadSignedRequestImage(imageName: String, signedURL: String, contentType: String, renewedSignedURL: Bool = false) -> Promise<DownloadResult> {
        return Promise<DownloadResult>(on: queue) { fulfill, reject in

            let headers: HTTPHeaders = [
                "Content-Type": contentType,
            ]

            Alamofire.request(signedURL, method: .get, headers: headers).response(queue: self.queue) { response in

                if let error = response.error {
                    reject(error)
                    return
                }

                guard let code = response.response?.statusCode else {
                    reject(APIError.noResponseCode)
                    return
                }

                guard let data = response.data else {
                    reject(DownloadAPIError.unknonwn)
                    return
                }

                if code == 200 {
                    let result = DownloadResult(data: data, error: nil, reason: nil)
                    fulfill(result)
                } else {
                    if renewedSignedURL {
                        // Request a sign url and repeat
                        let result = DownloadResult(data: nil, error: DownloadAPIError.signError, reason: "Issue with the signarute")
                        fulfill(result)
                    } else {
                        // Request new signature and try this method again
                        self.requestImageSignedURL(resourceName: imageName).then(on: self.queue) { result in
                            guard let newSignedURL = result.signedURL else {
                                reject(DownloadAPIError.reqSignedAPIURLFailed)
                                return
                            }
                            self.downloadSignedRequestImage(imageName: imageName,
                                                            signedURL: newSignedURL,
                                                            contentType: contentType,
                                                            renewedSignedURL: true).then(on: self.queue) { newResult in
                                fulfill(newResult)
                            }.catch { error in
                                reject(error)
                            }
                        }.catch { _ in
                            reject(DownloadAPIError.reqSignedURLFailed)
                        }
                    }
                }
            }
        }
    }

    func requestImageSignedURL(resourceName: String) -> Promise<ImageSignReqResponse> {
        return Promise<ImageSignReqResponse> { fulfill, reject in
            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let url = self.backend.downloadReSignedURLFor()

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: String] = [
                "resource_name": resourceName,
            ]

            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString),
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

                guard let imageSignReqResponse = Mapper<ImageSignReqResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(imageSignReqResponse)
            }
        }
    }
}

enum DownloadAPIError: Error {
    case unknonwn
    case signError
    case reqSignedURLFailed
    case reqSignedAPIURLFailed
}
