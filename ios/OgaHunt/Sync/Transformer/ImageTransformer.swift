//
//  ImageTransformer.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/4/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

extension Image {
    func merge(imageResponse: ImageResponse) {
        contentType = imageResponse.contentType
        id = imageResponse.id ?? -1
        imageDeleted = imageResponse.isDeleted ?? false
        imageURL = imageResponse.imageURL

        signedImageURL = imageResponse.signedImageURL
        contentType = imageResponse.contentType

        if let tstamp = imageResponse.expiresTStamp {
            let date = NSDate(timeIntervalSince1970: Double(tstamp))
            expires = date
        }

        if let insertedAt = imageResponse.insertedAt {
            if let date = insertedAt.parseDate() {
                self.insertedAt = date as NSDate
            } else {
                log.warning("Can't parse date: \(insertedAt). Ignoring")
            }
        }
    }
}

extension ImageResponse {}
