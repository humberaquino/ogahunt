//
//  UIKit+utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 7/11/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

extension UIView {
    func removeAllSubView() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
