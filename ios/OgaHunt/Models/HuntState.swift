//
//  MainHuntStateManager.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

enum HuntState {
    case mediaAndLocation
//    case location
    case details
    case done

    func nextState() -> HuntState {
        switch self {
        case .mediaAndLocation:
            return .details
        case .details:
            return .done
        case .done:
            return .done
        }
    }
}
