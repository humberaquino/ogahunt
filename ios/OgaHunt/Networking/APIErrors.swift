//
//  APIErrors.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

enum APIError: Error {
    case failedRequest(cause: String)
    case invalidRequest(cause: String)
    case errorRequest(code: Int, cause: String)
    case invalidResponseValue
    case invalidJSON(responseBody: String)

    case noTeamSelected
    case noAuthValue
    case noResponseCode
}
