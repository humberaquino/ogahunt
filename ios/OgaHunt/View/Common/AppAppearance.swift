//
//  AppAppearance.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/14/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class AppAppearance {
    static let shared = AppAppearance()

    private init() {}

    private enum Keys {
        static let selectedTheme = "SelectedTheme"
    }

//    var selectedTheme: Theme?

    static var current: Theme? {
        guard let storedThemeName = UserDefaults.standard.string(forKey: Keys.selectedTheme) else {
            return nil
        }

        return Theme.getThemeBy(name: storedThemeName) // ?? Theme.defaultTheme()
    }
    
//    static func ()  {
//        let app = UINavigationBarAppearance()
//        app.backgroundColor = UINavigationBar.appearance().barTintColor
//        self.navigationController?.navigationBar.scrollEdgeAppearance = app
//    }

    func set(theme: Theme) {
        UserDefaults.standard.set(theme.name.rawValue, forKey: Keys.selectedTheme)
        UserDefaults.standard.synchronize()
    }

    func apply() {
        guard let theme = AppAppearance.current else {
            print("No theme selected")
            return
        }

        // Save the current selected theme
        set(theme: theme)

        UIApplication.shared.delegate?.window??.tintColor = theme.mainColor

        // Navigation bar
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().barTintColor = theme.barTintColor
        UINavigationBar.appearance().tintColor = theme.tintColor
        UINavigationBar.appearance().isTranslucent = false

        let attrs = [
            NSAttributedString.Key.foregroundColor: theme.largeTitleColor,
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs

        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = attrs
        }

        // Selected tabbar
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: theme.tabBarSelected], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: theme.tabBarNormal], for: .normal)

        // Selected item color
        UITabBar.appearance().tintColor = theme.tabBarTint

        // Tab bar background color
        UITabBar.appearance().backgroundColor = theme.tabBarBg
        UITabBar.appearance().barTintColor = theme.tabBarBarTint

        UITabBar.appearance().unselectedItemTintColor = theme.tabBatUnselectedItemTint

        // Table view
        UITableView.appearance().backgroundColor = theme.tableViewBg
        //        UITableView.appearance().rowHeight = 40
        //        UITableView.appearance().separatorStyle = .None
        UITableViewCell.appearance().backgroundColor = theme.tableViewCellBg

        UIRefreshControl.appearance().tintColor = theme.refreshTextColor
        UIRefreshControl.appearance().backgroundColor = theme.barTintColor
    }
}
