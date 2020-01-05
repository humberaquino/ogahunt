//
//  VersionUtils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class VersionUtils {
    static func currentVersion() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"),
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") else {
            return "unknown"
        }

        return "\(version) (\(build))"
    }
}
