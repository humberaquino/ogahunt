//
//  ImagesResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/30/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 id: image.id,
 image_url: image.image_url,
 is_deleted: image.is_deleted,
 inserted_at: image.inserted_at
 */
class ImageResponse: Mappable {
    var id: Int64?
    var imageURL: String?
    var isDeleted: Bool?
    var insertedAt: String?

    var signedImageURL: String?
    var expiresTStamp: Int?
    var contentType: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        imageURL <- map["image_url"]
        isDeleted <- map["is_deleted"]
        insertedAt <- map["inserted_at"]

        signedImageURL <- map["signed_image_url"]
        expiresTStamp <- map["expires_tstamp"]
        contentType <- map["content_type"]
    }
}
