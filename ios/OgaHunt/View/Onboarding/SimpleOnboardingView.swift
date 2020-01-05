//
//  SimpleOnboardingView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class SimpleOnboardingView: UIView {
    var titleLabel: UILabel!

    var startButton: UIButton!

    convenience init() {
        self.init(frame: CGRect.zero)

        render()
    }

    func render() {
        buildElements()
        buildLayout()
    }

    func buildElements() {}

    func buildLayout() {}
}
