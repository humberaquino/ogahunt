//
//  EstateFilterModel.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

struct EstateFilterModel {
    var sortBy = EstateFilterSortBy.updatedAt
    var sortOrder = SortOrder.desc
    var listOnly = EstateFilterListOnly.open

    static func == (lhs: EstateFilterModel, rhs: EstateFilterModel) -> Bool {
        return lhs.sortBy == rhs.sortBy
            && lhs.sortOrder == rhs.sortOrder
            && lhs.listOnly == rhs.listOnly
    }
}

enum SortOrder: String {
    static let total = 2
    static let defaultOption = desc
    static let allvalues = [desc, asc]

    case desc
    case asc
}

enum EstateFilterSortBy: String {
    static let total = 3
    static let allvalues = [createdAt, updatedAt, name]
    static let defaultOption = createdAt

    case createdAt
    case updatedAt
    case name
}

enum EstateFilterListOnly: String {
    static let total = 2
    static let allvalues = [open, archived, all]
    static let defaultOption = open

    case open
    case archived
    case all
}
