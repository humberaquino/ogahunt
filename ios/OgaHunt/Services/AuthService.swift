//
//  AuthService.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class AuthService {
    struct Keys {
        static let UserId = "userId"
        static let Email = "email"
        static let Password = "password"
        static let ApiToken = "api-token"
        static let TeamId = "team-id"
        static let TeamName = "team-name"
        static let TeamRole = "team-role"
    }

    func requiresLogin() -> Bool {
        return apiToken() == nil
    }

    func apiToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.ApiToken)
    }

    func email() -> String? {
        return UserDefaults.standard.string(forKey: Keys.Email)
    }

    func userId() -> Int64? {
        guard let userIdStr = UserDefaults.standard.string(forKey: Keys.UserId) else {
            return nil
        }

        return Int64(userIdStr)
    }

    func saveSuccessAuth(userId: Int64, email: String, apiToken: String, team: Team) {
        UserDefaults.standard.set("\(userId)", forKey: Keys.UserId)
        UserDefaults.standard.set(email, forKey: Keys.Email)
        UserDefaults.standard.set(apiToken, forKey: Keys.ApiToken)

        let teamIdStr = "\(team.id)"
        UserDefaults.standard.set(teamIdStr, forKey: Keys.TeamId)
        UserDefaults.standard.set(team.name, forKey: Keys.TeamName)
        UserDefaults.standard.set(team.role, forKey: Keys.TeamRole)

        UserDefaults.standard.synchronize()

        // Select hunting list
        NotificationCenter.default.post(name: .authLogin, object: nil)
    }

    func currentTeam() -> Team? {
        guard let name = UserDefaults.standard.string(forKey: Keys.TeamName),
            let idStr = UserDefaults.standard.string(forKey: Keys.TeamId),
            let role = UserDefaults.standard.string(forKey: Keys.TeamRole) else {
            return nil
        }
        let id = Int64(idStr)!
        return Team(name: name, id: id, role: role)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: Keys.ApiToken)
//        UserDefaults.standard.removeObject(forKey: Keys.Email)
        // Select hunting list
        NotificationCenter.default.post(name: .authLogout, object: nil)
    }
}

extension Notification.Name {
    static let authLogout = Notification.Name("auth.logout")
    static let authLogin = Notification.Name("auth.login")
}
