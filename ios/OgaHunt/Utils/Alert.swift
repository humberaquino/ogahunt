//
//  Alert.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

struct Alert {
    static func simpleOk(title: String, message: String, onClose: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            onClose?()
        }))
        return alert
    }

    static func simple(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }

    static func simple(title: String, message: String, onClose: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            onClose?()
        }))
        return alert
    }
}
