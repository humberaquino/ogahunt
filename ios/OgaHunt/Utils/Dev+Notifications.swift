//
//  Dev+Notifications.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//
import UIKit

public extension NSObject {
    public func on(_ event: String, _ callback: @escaping () -> Void) {
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: event),
                                                   object: nil,
                                                   queue: nil) { _ in
            callback()
        }
    }
}
