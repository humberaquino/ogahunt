//
//  Logger.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import AELog
import Foundation

class Logger {
    static let shared = Logger()

    func setup() {
        let settings = Log.shared.settings

        settings.isEnabled = true
        settings.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        settings.template = "{date} -- [{thread}] {file} ({line}) -> {function} > {text}"
    }

    func info(_ msg: String) {
        aelog(msg)
    }

    func debug(_ msg: String) {
        aelog(msg)
    }

    func error(_ msg: String) {
        aelog(msg)
    }

    func error(_ error: Error) {
        aelog(error.localizedDescription)
    }

    func warning(_ msg: String) {
        aelog(msg)
    }

}
