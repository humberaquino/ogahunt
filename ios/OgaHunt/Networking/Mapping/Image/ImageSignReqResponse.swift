//
//  ImageSignReqResponse.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageSignReqResponse: Mappable {
    var signedURL: String?
    var expires: UInt?
    var resourceName: String?

    required init?(map _: Map) {}

    func mapping(map: Map) {
        signedURL <- map["signed_url"]
        expires <- map["expires"]
        resourceName <- map["resource_name"]
    }
}
