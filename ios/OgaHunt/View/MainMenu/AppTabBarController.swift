//
//  AppTabBarController.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import UIKit

class AppTabBarController: UITabBarController, UITabBarControllerDelegate {
    var coreDataStack: CoreDataStack!

    var menuButton: UIButton!
    var configured = false

    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Delay config intil is shown
        configUIIfnecesary()
    }

    // Tab Bar Specific Code
    func setupWithStack(stack: CoreDataStack) {
        coreDataStack = stack
    }

    func configUIIfnecesary() {
        if configured {
            return
        }
        configured = true

        let estateListVC = EstateListVC()
        estateListVC.setup(title: "Hunt list", isAssignedTo: false, stack: coreDataStack)
        let estateIcon = UIImage(named: "list")
        estateListVC.tabBarItem = UITabBarItem(title: "Hunt list", image: estateIcon, tag: 1)
        
        let nav1 = UINavigationController(rootViewController: estateListVC)
        nav1.modalPresentationStyle = .fullScreen
        updateAppeareance(nav: nav1)
        

        let huntingListVC = EstateListVC()
        huntingListVC.setup(title: "Hunting", isAssignedTo: true, stack: coreDataStack)
        let huntIcon = UIImage(named: "hunt")
        huntingListVC.tabBarItem = UITabBarItem(title: "Hunting", image: huntIcon, tag: 2)
        let nav2 = UINavigationController(rootViewController: huntingListVC)
        updateAppeareance(nav: nav2)

        let controller3 = UIViewController()
        let nav3 = UINavigationController(rootViewController: controller3)
        nav3.title = ""
        updateAppeareance(nav: nav3)

        let eventsVC = EstateEventsVC()
        let bellIcon = UIImage(named: "events")
        eventsVC.setup(stack: coreDataStack)
        eventsVC.tabBarItem = UITabBarItem(title: "Activities", image: bellIcon, tag: 4)
        let nav4 = UINavigationController(rootViewController: eventsVC)
        updateAppeareance(nav: nav4)

        let settingsVC = SettingsVC()
        settingsVC.setup(stack: coreDataStack)
        let settingsIcon = UIImage(named: "settings")
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: settingsIcon, tag: 5)
        let nav5 = UINavigationController(rootViewController: settingsVC)
        updateAppeareance(nav: nav5)

        viewControllers = [nav1, nav2, nav3, nav4, nav5]

        // Disable unused middle tabbar item
        tabBar.items?[2].isEnabled = false

        setupMiddleButton()
    }
    
    func updateAppeareance(nav: UINavigationController) {
        if #available(iOS 13.0, *) {
            let app = UINavigationBarAppearance()
            app.backgroundColor = UINavigationBar.appearance().barTintColor
            nav.navigationBar.scrollEdgeAppearance = app
       }
    }

    // TabBarButton – Setup Middle Button
    func setupMiddleButton() {
        menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        var menuButtonFrame = menuButton.frame

        var bottomInsets: CGFloat = 0
        if #available(iOS 11, *) {
            bottomInsets = view.safeAreaInsets.bottom
        }

        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - bottomInsets
        menuButtonFrame.origin.x = view.bounds.width / 2 - menuButtonFrame.size.width / 2
        menuButton.frame = menuButtonFrame

        if let currentTheme = AppAppearance.current {
            menuButton.backgroundColor = currentTheme.mainHuntButtonBg
            menuButton.tintColor = currentTheme.mainHuntButtonTint
        }
        menuButton.layer.cornerRadius = menuButtonFrame.height / 2
        view.addSubview(menuButton)

        let plusIcon = UIImage(named: "add-location")!.withRenderingMode(.alwaysTemplate)

        if let color = AppAppearance.current?.mainHuntButtonBg {
            menuButton.backgroundColor = color
        }

        menuButton.setImage(plusIcon, for: UIControl.State.normal)

        menuButton.addTarget(self, action: #selector(AppTabBarController.menuButtonAction), for: UIControl.Event.touchUpInside)
        view.layoutIfNeeded()
    }

    // Menu Button Touch Action
    @objc func menuButtonAction(sender _: UIButton) {
        // console print to verify the button works
        print("Middle Button was just pressed!")

        let permUtils = PermUtils()
        if permUtils.appHasAllPerms() {
            if permUtils.appHasSomeRestrictions() {
                presentPermRestrictionMsg()

            } else {
                let mainEstateHunt = MainEstateHuntVC()
                mainEstateHunt.setupPersistence(coreDataStack: coreDataStack)
                present(mainEstateHunt, animated: true, completion: nil)
            }

        } else {
            if let missingPerm = permUtils.currentMissingPerm() {
                let permRequesterVC = PermRequesterVC()
                permRequesterVC.setup(coreDataStack: coreDataStack, permUtils: permUtils, originalController: self)

                permRequesterVC.missingPerm = missingPerm
                //            navigationController?.pushViewController(permRequesterVC, animated: true)
                let nav = UINavigationController(rootViewController: permRequesterVC)
                present(nav, animated: true, completion: nil)
            } else {
                if permUtils.appHasSomeRestrictions() {
                    presentPermRestrictionMsg()
                } else {
                    presentPermIssueMsg()
                }
            }
        }
    }

    func presentPermRestrictionMsg() {
        // show alert for now
        let msg = "One or more permissions are missing. Please go to settings and enable them to be abel to hunt"
        let alert = Alert.simple(title: "Missing permissions", message: msg)

        present(alert, animated: true)
    }

    func presentPermIssueMsg() {
        // show alert for now
        let msg = "One or more permissions are having problems. Please go to settings and enable them to be abel to hunt"
        let alert = Alert.simple(title: "Permission problem", message: msg)

        present(alert, animated: true)
    }

    func hide() {
        DispatchQueue.main.async {
            self.tabBar.isHidden = true
            self.menuButton.isHidden = true
        }
    }

    func unhide() {
        DispatchQueue.main.async {
            self.tabBar.isHidden = false
            self.menuButton.isHidden = false
        }
    }
}
