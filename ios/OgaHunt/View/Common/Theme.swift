//
//  Theme.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIColor_Hex_Swift
import UIKit

struct DefaultColors {
    //  Dark gray: 45    54    62
    static let first = UIColor(red: 45.0 / 255.0, green: 54.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
    // Vivid pink: 228    90    124
    static let second = UIColor(red: 228.0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1.0)
    // Light cream: 242    245    235
    static let third = UIColor(red: 242.0 / 255.0, green: 245.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    // Light gray: 214    219    211
    static let forth = UIColor(red: 214.0 / 255.0, green: 219.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
    // Light gren: 187    199    166
    static let fifth = UIColor(red: 187.0 / 255.0, green: 199.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0)
}

//////////////////////////// Activo
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
// Palette: https://coolors.co/ff9f1c-ffbf69-ffffff-cbf3f0-2ec4b6
struct YellowAndGreenColors {
    static let gray = UIColor("#404040")
    static let yellow = UIColor("#FF9F1C")
    static let yellowLight = UIColor("#FFC372")
    static let melon = UIColor("#FFBF69")
    static let white = UIColor("#FFFFFF")
    static let cyan = UIColor("#CBF3F0")
    static let lightGreen = UIColor("#2EC4B6")
    static let veryLightGray = UIColor("#D9D9D9")
    static let red = UIColor("#FF0000")
}

struct Theme {
    let name: ThemeName
    let mainColor: UIColor
    let barStyle: UIBarStyle
    let barTintColor: UIColor
    let tintColor: UIColor
    let largeTitleColor: UIColor

    let tabBarSelected: UIColor
    let tabBarNormal: UIColor
    let tabBarTint: UIColor

    let tabBarBg: UIColor
    let tabBarBarTint: UIColor

    let tableViewBg: UIColor
    let tableViewCellBg: UIColor

    let mainHuntButtonBg: UIColor
    let tabBatUnselectedItemTint: UIColor

    let mainHuntButtonTint: UIColor
    let tableViewCellPrice: UIColor

    let tableViewActiveIcon: UIColor
    let tableViewDisabledIcon: UIColor

    let tableViewAssignBg: UIColor
    let tableViewArchiveBg: UIColor
    let tableViewDeleteBg: UIColor

    let refreshTextColor: UIColor

    let sectionBg: UIColor
    let sectionText: UIColor

    enum ThemeName: String {
//        case `default`
        case yellowAndGreen
//        case darkBlueRedYellow
//        case greenAndBlueColors
    }

    static func getThemeBy(name: String) -> Theme? {
        guard let themeName = ThemeName(rawValue: name) else {
            return nil
        }

        return themes[themeName]
    }

    static let themes: [ThemeName: Theme] = [
//        ThemeName.default: defaultTheme()
        ThemeName.yellowAndGreen: yellowishTheme(),
//        ThemeName.darkBlueRedYellow: darkBlueRedYellowTheme(),
//        ThemeName.greenAndBlueColors: greenAndBlueColorsTheme(),
    ]

    // MARK: - Themes

    // Activo
    static func yellowishTheme() -> Theme {
        return Theme(name: ThemeName.yellowAndGreen,
                     mainColor: YellowAndGreenColors.yellow,
                     barStyle: UIBarStyle.default,
                     barTintColor: YellowAndGreenColors.lightGreen,
                     tintColor: YellowAndGreenColors.gray,
                     largeTitleColor: YellowAndGreenColors.gray,
                     tabBarSelected: YellowAndGreenColors.melon,
                     tabBarNormal: YellowAndGreenColors.white,
                     tabBarTint: YellowAndGreenColors.yellow,
                     tabBarBg: YellowAndGreenColors.yellow,
                     tabBarBarTint: YellowAndGreenColors.gray,
                     tableViewBg: YellowAndGreenColors.white,
                     tableViewCellBg: YellowAndGreenColors.white,
                     mainHuntButtonBg: UIColor.lightGray,
                     tabBatUnselectedItemTint: YellowAndGreenColors.white,
                     mainHuntButtonTint: YellowAndGreenColors.white,
                     tableViewCellPrice: YellowAndGreenColors.melon,
                     tableViewActiveIcon: YellowAndGreenColors.melon,
                     tableViewDisabledIcon: YellowAndGreenColors.veryLightGray,
                     tableViewAssignBg: YellowAndGreenColors.yellow,
                     tableViewArchiveBg: UIColor.lightGray,
                     tableViewDeleteBg: YellowAndGreenColors.red,
                     refreshTextColor: YellowAndGreenColors.white,
                     sectionBg: YellowAndGreenColors.yellowLight,
                     sectionText: YellowAndGreenColors.gray)
    }
}
