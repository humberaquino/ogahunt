//
//  ErrorMessageHandler.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class ErrorMessageHandler {
    static func extractErrorDescription(_ error: Error) -> String {
        switch error {
        case let apiError as APIError:

            switch apiError {
            case let .failedRequest(reason):
                return "Failed request: \(reason)"

            case let .invalidRequest(cause):
                return "Invalid request: \(cause)"

            case let .errorRequest(code, cause):
                return "Request error: \(cause). HCode: \(code)"

            case .invalidResponseValue:
                return "Invalid response"

            case let .invalidJSON(responseBody):
                return "Malformed response: \(responseBody)"

            case .noTeamSelected:
                return "Bug found: No team selected"

            case .noAuthValue:
                return "Bug found: No authorization token found"

            case .noResponseCode:
                return "No response code from the server"
            }

        case let signinError as SigninError:

            switch signinError {
            case let .failedRequest(cause):
                return "Failed request: \(cause)"
            case let .invalidJSON(responseBody):
                return "Invalid response: \(responseBody)"
            case let .invalidRequest(cause):
                return "Invalid request: \(cause)"
            case .invalidResponseValue:
                return "Invalid response from the server"
            }

        default:
            return error.localizedDescription
        }
    }
}
