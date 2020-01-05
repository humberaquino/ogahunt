//
//  SettingsService.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class SettingsService {
    struct Keys {
        static let UserStatuses = "settings.user-statuses"
        static let Roles = "settings.roles"
        static let EstateTypes = "settings.estate-types"
        static let EstateStatuses = "settings.estate-statuses"
        static let Currencies = "settings.currencies"
    }

    func userStatusBy(id: Int64) -> String? {
        return getMapValue(key: Keys.UserStatuses, id: id)
    }

    func rolesBy(id: Int64) -> String? {
        return getMapValue(key: Keys.Roles, id: id)
    }

    func estateTypeBy(id: Int64) -> String? {
        return getMapValue(key: Keys.EstateTypes, id: id)
    }

    func estateStatusBy(id: Int64) -> String? {
        return getMapValue(key: Keys.EstateStatuses, id: id)
    }

    func currencyBy(id: Int64) -> String? {
        return getMapValue(key: Keys.Currencies, id: id)
    }

    func estateTypeValues() -> [String] {
        guard let map = getMap(forKey: Keys.EstateTypes) else {
            return []
        }

        var list = Array(map.values) as! [String]
        list.sort()
        return list
    }

    private func getMap(forKey key: String) -> [String: Any]? {
        guard let map = UserDefaults.standard.dictionary(forKey: key) else {
            return nil
        }

        return map
    }

    private func getMapValue(key: String, id: Int64) -> String? {
        guard let map = getMap(forKey: key) else {
            return nil
        }
        return map[String(id)] as? String
    }

    func saveSettings(settingsResponse: SettingsResponse) throws {
        if let userStatuses = settingsResponse.userStatuses {
            var map: [String: String] = [:]
            try userStatuses.forEach { userStatus in
                print(userStatus)
                if let id = userStatus.id, let name = userStatus.name {
                    map[String(id)] = name
                } else {
                    throw SettingServiceError.invalidUserStatus
                }
            }

            UserDefaults.standard.set(map, forKey: Keys.UserStatuses)
        }

        if let roles = settingsResponse.roles {
            var map: [String: String] = [:]
            try roles.forEach { role in
                if let id = role.id, let name = role.name {
                    map[String(id)] = name
                } else {
                    throw SettingServiceError.invalidRole
                }
            }

            UserDefaults.standard.set(map, forKey: Keys.Roles)
        }

        if let estateTypes = settingsResponse.estateTypes {
            var map: [String: String] = [:]
            try estateTypes.forEach { estateType in
                if let id = estateType.id, let name = estateType.name {
                    map[String(id)] = name
                } else {
                    throw SettingServiceError.invalidEstateType
                }
            }

            UserDefaults.standard.set(map, forKey: Keys.EstateTypes)
        }

        if let estateStatuses = settingsResponse.estateStatuses {
            var map: [String: String] = [:]
            try estateStatuses.forEach { estateStatus in
                if let id = estateStatus.id, let name = estateStatus.name {
                    map[String(id)] = name
                } else {
                    throw SettingServiceError.invalidEstateStatus
                }
            }

            UserDefaults.standard.set(map, forKey: Keys.EstateStatuses)
        }

        if let currencies = settingsResponse.currencies {
            var map: [String: String] = [:]
            try currencies.forEach { currency in
                if let id = currency.id, let code = currency.code {
                    map[String(id)] = code
                } else {
                    throw SettingServiceError.invalidCurrency
                }
            }

            UserDefaults.standard.set(map, forKey: Keys.Currencies)
        }

        UserDefaults.standard.synchronize()
    }
}

enum SettingServiceError: Error {
    case invalidUserStatus
    case invalidEstateType
    case invalidCurrency
    case invalidEstateStatus
    case invalidRole
}
