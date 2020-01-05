//
//  UploadAPI.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import Promises

struct GCSUploadResult {
    let success: Bool
    let reason: String?
    let code: Int?
    let responseBody: String?
}

struct UploadImageResult {
    let resourceName: String
    let gcsUploadResult: GCSUploadResult
}

class UploadAPI {
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

    func upload(estateId: Int64, imageName: String, imageData: Data) -> Promise<UploadImageResult> {
        return Promise<UploadImageResult> { fulfill, reject in
            self.requestUploadToken(estateId: estateId, imageName: imageName).then { result in

                guard let signedURL = result.signedURL,
                    let resourceName = result.resourceName else {
                    reject(UploadError.signedURLMissing)
                    return
                }

                self.uploadUsing(signedURL: signedURL, imageData: imageData).then { uploadResult in
                    let res = UploadImageResult(resourceName: resourceName, gcsUploadResult: uploadResult)
                    fulfill(res)
                }.catch { error in
                    reject(error)
                }
            }.catch { error in
                reject(error)
            }
        }
    }

    func saveUploadedImage(estateId: Int64, resourceName: String, saveEvent: Bool = true) -> Promise<ResultResponse> {
        return Promise<ResultResponse> { fulfill, reject in

            guard let req = Mapper<SaveUploadedImageRequest>().map(JSONString: "{}") else {
                reject(UploadError.cantCreateRequest)
                return
            }

            req.estateId = estateId
            req.resourceName = resourceName
            req.saveEvent = saveEvent

            let jsonBody = req.toJSON()

            let url = self.backend.saveUploadedImage()

            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            Alamofire.request(url, method: .post, parameters: jsonBody,
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

                guard let result = Mapper<ResultResponse>().map(JSONString: value) else {
                    reject(APIError.invalidJSON(responseBody: value))
                    return
                }

                fulfill(result)
            }
        }
    }

    private func requestUploadToken(estateId: Int64, imageName: String) -> Promise<ImageSignReqResponse> {
        return Promise<ImageSignReqResponse> { fulfill, reject in
            guard let authValue = self.backend.basicAuthValue() else {
                reject(APIError.noAuthValue)
                return
            }

            let url = self.backend.reqSignedUploadURL()

            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": authValue,
            ]

            let parameters: [String: Any] = [
                "estate_id": estateId,
                "name": imageName,
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

    private func uploadUsing(signedURL: String, imageData: Data) -> Promise<GCSUploadResult> {
        return Promise<GCSUploadResult> { fulfill, reject in
            // Assume we deal with JPEG images only
            let headers = [
                "Content-Type": "image/jpeg",
            ]

            // presignedUrl is a String
            Alamofire.upload(imageData, to: signedURL, method: .put, headers: headers)
                .uploadProgress { progress in // main queue by default
                    print("Upload Progress: \(progress.fractionCompleted)")
                }.responseString { response in
                    if let code = response.response?.statusCode {
                        let value = response.result.value

                        if code == 400 {
                            fulfill(GCSUploadResult(success: false, reason: "Invalid request", code: code, responseBody: value))
                        } else if code == 403 {
                            fulfill(GCSUploadResult(success: false, reason: "Sign issue", code: code, responseBody: value))
                        } else if code == 200 {
                            // All right!
                            fulfill(GCSUploadResult(success: true, reason: nil, code: code, responseBody: value))
                        } else {
                            fulfill(GCSUploadResult(success: false, reason: "Unknonw issue", code: code, responseBody: value))
                        }

                    } else {
                        reject(APIError.invalidResponseValue)
                    }
                }
        }
    }
}

enum UploadError: Error {
    case signedURLMissing
    case cantCreateRequest
}
