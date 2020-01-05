//
//  Environment.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

public enum PlistKey {
    case apiHost
    case apiScheme

    func value() -> String {
        switch self {
        case .apiHost:
            return "oh_api_host"
        case .apiScheme:
            return "oh_api_scheme"
        }
    }
}

public struct Environment {
    fileprivate var infoDict: [String: Any] {
        if let dict = Bundle.main.infoDictionary {
            return dict
        } else {
            fatalError("Plist file not found")
        }
    }

    public func configuration(_ key: PlistKey) -> String {
        switch key {
        case .apiHost:
            return infoDict[PlistKey.apiHost.value()] as! String
        case .apiScheme:
            return infoDict[PlistKey.apiScheme.value()] as! String
        }
    }

    public func serverURL() -> String {
        return "\(configuration(.apiScheme))://\(configuration(.apiHost))"
    }
}
