//
//  Estate+CoreDataClass.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
//

import CoreData
import DateToolsSwift
import Foundation
import UIKit

@objc(Estate)
public class Estate: NSManagedObject {}

class EstateType {
    private let value: String

    init(value: String) {
        self.value = value
    }

    static func allValues() -> [String] {
        let settingsService = SettingsService()
        return settingsService.estateTypeValues()
    }

    static func defaultValue() -> String? {
        return allValues().first
    }
}

extension Estate {
    struct Limits {
        static let MinNameCount = 4
        static let MaxNameCount = 200
    }

    // This can be hardcoded because depends a lot on the app behavior
    struct Status {
        static let Open = "open"
        static let Archived = "archived"
        static let Unknown = "unknown"
    }

    func keyImage() -> UIImage? {
        guard let images = self.images,
            let firstImage = images.firstObject as? Image,
            let imagePath = firstImage.localPath else {
            return nil
        }

        let dataManager = DataManager()
        let image = dataManager.imageFrom(string: imagePath)
        return image
    }

    func allImages() -> [UIImage] {
        guard let images = self.images else { return [] }

        let dataManager = DataManager()

        var result: [UIImage] = []

        for image in images {
            if let estateImage = image as? Image,

                let imagePath = estateImage.localPath {
                if let uiimage = dataManager.imageFrom(string: imagePath) {
                    result.append(uiimage)
                }
            }
        }

        return result
    }

    func allImagesURLs() -> [String] {
        guard let images = self.images else { return [] }

        var result: [String] = []

        for image in images {
            if let estateImage = image as? Image,
                let imageURL = estateImage.imageURL {
                result.append(imageURL)
            }
        }

        return result
    }

    func latestPrice() -> Price? {
        guard let prices = self.prices else { return nil }

        var latest: Price!
        for case let price as Price in prices {
            if latest == nil {
                latest = price
            } else {
                if let priceCreatedAt = price.createdAt as Date?,
                    let latestCreatedAt = latest.createdAt as Date? {
                    if priceCreatedAt.isLaterThanOrEqual(to: latestCreatedAt) {
                        latest = price
                    }
                }
            }
        }

        return latest
    }

    func possibleArchiveAction() -> String {
        if let status = self.status {
            if status == Estate.Status.Open {
                return "Archive"
            } else {
                return "Unarchive"
            }
        } else {
            return "Archive"
        }
    }

    func possibleAssignAction() -> String {
        if assignedTo != nil {
            return "Unassign"
        } else {
            return "Assign"
        }
    }

    func toogleStatus() -> String {
        if let status = self.status {
            if status == Estate.Status.Archived {
                return Estate.Status.Open
            } else {
                return Estate.Status.Archived
            }
        } else {
            // No status yet. set it to open
            return Estate.Status.Open
        }
    }

    func hasImageNeedingDownload() -> Bool {
        guard let images = self.images?.array as? [Image] else {
            return false
        }

        if images.isEmpty {
            return false
        }

        for image in images {
            // No local but has something to download
            if image.localPath == nil && image.imageURL != nil {
                return true
            }
        }

        return false
    }
}
