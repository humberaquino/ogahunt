//
//  APIBackend.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/24/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class Backend {
    // Singleton
    static let global = Backend()

    var baseURL: String = ""
    let authService = AuthService()

    func setup(baseURL: String) {
        self.baseURL = baseURL
    }

    func loginURL() -> String {
        return "\(baseURL)/api/signin"
    }

    func registerURL() -> String {
        return "\(baseURL)/api/register"
    }

    func apiToken() -> String? {
        return authService.apiToken()
    }

    func currentTeam() -> Team? {
        return authService.currentTeam()
    }

    func basicAuthValue() -> String? {
        // get token, prepend email, encode to base 64, prepend basic
        guard let email = authService.email(),
            let apiToken = authService.apiToken() else {
            return nil
        }

        let authPair = "\(email):\(apiToken)"
        let encoded = authPair.toBase64()

        return "Basic \(encoded)"
    }

    func teamContactListURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/contacts"
    }

    func teamEstateListURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate"
    }

    func settingsURL() -> String {
        return "\(baseURL)/api/settings"
    }

    func teamUsersURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/users"
    }

    func teamUserInvitationsURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/users/invitations"
    }

    func teamUserInvitateURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/users/invite"
    }

    func teamEstateCreateURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate"
    }

    func teamEstateUpdateURL(teamId: Int64, estateId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate/\(estateId)"
    }

    func teamEstateAssignURL(teamId: Int64, estateId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate/\(estateId)/assign"
    }

    func teamEstateDeleteURL(teamId: Int64, estateId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate/\(estateId)"
    }

    func teamEstateUpdateLocationURL(teamId: Int64, estateId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate/\(estateId)/location"
    }

    func teamEstateUpdateStatusURL(teamId: Int64, estateId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/estate/\(estateId)/status"
    }

    func reqSignedUploadURL() -> String {
        return "\(baseURL)/api/image/upload/req_signed_url"
    }

    func saveUploadedImage() -> String {
        return "\(baseURL)/api/image/save_uploaded"
    }

    func downloadReSignedURLFor() -> String {
        return "\(baseURL)/api/image/download/req_signed_url"
    }

    func teamContactCreateURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/contacts"
    }

    func teamContactUpdateURL(teamId: Int64, contactId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/contacts/\(contactId)"
    }

    func teamEstateEventsURL(teamId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/events"
    }

    func teamContactDeleteURL(teamId: Int64, contactId: Int64) -> String {
        return "\(baseURL)/api/team/\(teamId)/contacts/\(contactId)"
    }
}
