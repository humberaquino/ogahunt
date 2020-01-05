//
//  BaseAuthVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class BaseAuthVC: UIViewController {
    let authService = AuthService()

    override func viewDidLoad() {
        super.viewDidLoad()

        on(Dev.INJECTION_BUNDLE_NOTIFICATION) {
            self.setupUI()
        }

        setupUI()
    }

    func setupUI() {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
