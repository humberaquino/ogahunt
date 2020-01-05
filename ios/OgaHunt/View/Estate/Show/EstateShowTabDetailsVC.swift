//
//  EstateInfoTabVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Pageboy
import Tabman
import UIKit

class EstateShowTabDetailsVC: TabmanViewController, PageboyViewControllerDataSource {
    let estateInfoVC = EstateInfoVC()
    let estateMainContactVC = EstateContactVC()
    let estateMapVC = EstateMapVC()

    let barItems = [
        Item(title: "Info"),
        Item(title: "Map"),
        Item(title: "Contact"),
    ]
    lazy var viewControllers: [UIViewController] = {
        [estateInfoVC, estateMapVC, estateMainContactVC]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure the bar
        bar.items = barItems

        view.backgroundColor = UIColor.white

        dataSource = self
    }

    func setupWith(estate: Estate) {
        estateInfoVC.configWith(estate: estate)
        estateMainContactVC.configWith(estate: estate)
        estateMapVC.configWith(estate: estate)
    }

    func reloadUI() {
        estateInfoVC.reloadUI()
        estateMainContactVC.reloadUI()
        estateMapVC.reloadUI()
    }

    func numberOfViewControllers(in _: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for _: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for _: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
