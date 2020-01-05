//
//  String+Utils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

extension String {
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0 ..< length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }

    /// Checks if the `String` is a valid email address.
    /// ````
    /// // Example
    /// "name@email.com".isValidEmailAddress() // true
    /// "name(at)email(dot)com".isValidEmailAddress() // false
    /// "name@email".isValidEmailAddress() // false
    /// "name@.com".isValidEmailAddress() // false
    /// "name.com".isValidEmailAddress() // false
    /// ````
    /// - Note: GitHubGist: [darthpelo/EmailValidator.swift](https://gist.github.com/darthpelo/dfe3c460585f4f035c24ede994faeb80#file-emailvalidator-swift)
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"
            + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
            + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
            + "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
            + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
            + "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
            + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

extension String {
    func htmlToAttributedString() -> NSAttributedString? {
        let modifiedFont = """
        <style>
        html * {font-size: 11.0pt !important;color: #383838 !important;font-family: Helvetica !important;}
        </style>

        \(self)
        """
        guard let data = modifiedFont.data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
}
