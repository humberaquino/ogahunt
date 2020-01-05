//
//  Device+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

struct DeviceLayout {
    static func deviceHeight() -> CGFloat {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        return height
    }

    static func baseKeyboardRiseHeight() -> CGFloat {
        if isSmallDevice() {
            return 200
        } else {
            return 100
        }
    }

    static func topMargin() -> CGFloat {
        var topMargin: CGFloat = 0
        if isSmallDevice() {
            topMargin = -130
        }
        return topMargin
    }

    static func isSmallDevice() -> Bool {
        let height = deviceHeight()
        return height <= 568
    }
}
