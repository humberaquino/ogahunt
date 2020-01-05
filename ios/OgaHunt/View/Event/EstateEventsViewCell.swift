//
//  EstateEventView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import Kingfisher
import SnapKit
import SwiftDate
import SwiftyJSON
import UIKit

// protocol EstateViewCellDelegate: class {
//    func requestImageDownload(estate: Estate)
// }

class EstateEventsViewCell: UITableViewCell {
    // user name
    let userName = UILabel()

    // event detail
    let eventDetails = UITextView()

    // event icon1
    let eventIcon = UIImageView()

    // event time
    let eventTime = UILabel()

    // Note: This is not great. Maybe I should move the user finding logic and config outside this class
    var userService: UserService!

    //    weak var delegate: EstateViewCellDelegate?

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
    }

    func render() {
        //        backgroundColor = .white
        //        name.textColor = .black

        userName.textColor = UIColor.darkGray
        userName.textAlignment = .left
        userName.font = UIFont.systemFont(ofSize: 12)

        eventTime.textColor = UIColor.lightGray
        eventTime.textAlignment = .center
        eventTime.font = UIFont.systemFont(ofSize: 10)

//        eventDetails.textColor = UIColor.darkGray
        eventDetails.textAlignment = .left
        eventDetails.font = UIFont.systemFont(ofSize: 14)
        eventDetails.isUserInteractionEnabled = false
        // Remove internal padding of the text
        eventDetails.textContainerInset = .zero
        eventDetails.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
//
//        lastPrice.textAlignment = .right
//        lastPrice.font = UIFont.systemFont(ofSize: 18)
//
        eventIcon.contentMode = .scaleAspectFit
        eventIcon.clipsToBounds = true
//
//        //        mainImage.layer.borderWidth = 10.0
//        //        mainImage.layer.borderColor = UIColor.red.cgColor
//        mainImage.layer.cornerRadius = 7.0
//
//        //        self.profileImageView.layer.borderWidth = 3.0f;
//        //        self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//
//        //        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
//        //        self.profileImageView.clipsToBounds = YES;
//
//        assignedTo.textColor = UIColor.darkGray
//        assignedTo.textAlignment = .right
//        assignedTo.font = UIFont.systemFont(ofSize: 10)
//        //        assignedTo.backgroundColor = UIColor.red
//
//        if let theme = AppAppearance.current {
//            address.backgroundColor = theme.tableViewBg
//            lastPrice.textColor = theme.tableViewCellPrice
//        }

        addSubview(userName)
        addSubview(eventTime)
        addSubview(eventIcon)
        addSubview(eventDetails)

        eventTime.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }

        eventIcon.snp.makeConstraints { make in
            make.centerX.equalTo(eventTime.snp.centerX)
            make.top.equalTo(self).offset(10)
            make.bottom.equalTo(eventTime.snp.top).offset(-5)
            make.width.equalTo(30)
        }

        userName.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.top.equalTo(5)
            make.height.equalTo(15)
            make.right.equalTo(eventIcon.snp.left).offset(-5)
        }

        eventDetails.snp.makeConstraints { make in
            make.left.equalTo(userName.snp.left)
            make.top.equalTo(userName.snp.bottom).offset(5)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(userName.snp.right)
        }

//        // Debug colors
//        userName.backgroundColor = .red
//        eventTime.backgroundColor = .yellow
//        eventDetails.backgroundColor = .green
//        eventIcon.backgroundColor = .blue
    }
}

extension EstateEventsViewCell {
    func populate(with event: EstateEvent, currentUserId: Int64?) {
        if let user = event.byUser {
            if let currentUserId = currentUserId, user.id == currentUserId {
                userName.text = "🦄 Me"
                backgroundColor = UIColor("#F8F8F8")
                eventDetails.backgroundColor = UIColor("#F8F8F8")
            } else {
                userName.text = user.name
                backgroundColor = .white
                eventDetails.backgroundColor = .white
            }
        } else {
            userName.text = "no-user 😨"
        }

        if let insertedAt = event.insertedAt as? Date {
            let text = insertedAt.toFormat("HH:mm")
            eventTime.text = text
        }

        if let changeType = event.changeType {
            if let image = imageFor(changeType: changeType) {
                eventIcon.image = image
            }

            if let estate = event.estate {
                // TODO: USE HTML
                eventDetails.attributedText = eventDeatilsFor(changeType: changeType, estate: estate, event: event)
//                eventDetails.text =
                selectionStyle = .default
            } else {
                if changeType == "estate_deleted" {
                    let name = getNameFromChange(event: event)
                    eventDetails.attributedText = "Deleted <b>\(name)</b>".htmlToAttributedString()
                } else {
                    eventDetails.text = "no-estate 😱"
                }

                selectionStyle = .none
            }
        }
    }

    fileprivate func eventDeatilsFor(changeType: String, estate: Estate, event: EstateEvent) -> NSAttributedString? {
//        let html = "\(action)"
        let name = estate.name ?? "no-name 🤔"
        let type = estate.type ?? "unknown 👻"

        switch changeType {
        case "estate_created":
            return "Created <b>\(type)</b> with name: <b>\(name)</b>".htmlToAttributedString()
        case "estate_deleted":
            return "Deleted <b>\(type)</b> named <b>\(name)</b>".htmlToAttributedString()
        case "estate_assigned":
            let userName = getUserNameFromChange(event: event)
            return "Assigned <b>\(type)</b> named <b>\(name)</b> to <b>\(userName)</b>".htmlToAttributedString()
        case "estate_unassigned":
            return "Unassigned <b>\(type)</b> named <b>\(name)</b>".htmlToAttributedString()
        case "estate_archived":
            return "Archived <b>\(type)</b> named <b>\(name)</b>".htmlToAttributedString()
        case "estate_open":
            return "Unarchived <b>\(type)</b> named <b>\(name)".htmlToAttributedString()
        case "estate_location_change":
            return "Changed the location of <b>\(type)</b> named <b>\(name)".htmlToAttributedString()
        case "estate_image_added":
            return "Added an image to <b>\(type)</b> named <b>\(name)".htmlToAttributedString()
        case "estate_details_updated":
            return eventDeatilsForUpdatedDetails(changeType: changeType, estate: estate, event: event)
        default:
            // unknown
            return "Did an Unknown change to <b>\(type)</b> named <b>\(name)</b>".htmlToAttributedString()
        }
    }

    private func eventDeatilsForUpdatedDetails(changeType _: String, estate: Estate, event: EstateEvent) -> NSAttributedString? {
        let name = estate.name ?? "no-name 🤔"
        let type = estate.type ?? "unknown 👻"

        guard let change = event.change else {
            return "Updated details for <b>\(type)</b> named <b>\(name)".htmlToAttributedString()
        }

        let json = JSON(parseJSON: change)

        let changesList = json["changes"].arrayValue

        // Check price change
        // {"key": "main_contact_id", "type": "set_value", "value": 16}

        // Price
        // {"key": "current_price", "type": "set_value", "value": "1312313.00"}

//        var priceChange:
        var meanfulchange = false
        var meainfulstr = ""
        changesList.forEach { json in
            let key = json["key"].stringValue
            if key == "main_contact_id" {
                meainfulstr = "Updated contact for <b>\(type)</b> named <b>\(name)"
                meanfulchange = true

                eventIcon.image = UIImage(named: "event-contact-changed")

            } else if key == "current_price" {
                let price = json["value"].stringValue

                if let formattedPrice = CurrencyUtils.formattedDecimalPrice(price: price) {
                    meainfulstr = "Updated price for <b>\(type)</b> named <b>\(name) to <b>\(formattedPrice)</b>"
                } else {
                    meainfulstr = "Updated price for <b>\(type)</b> named <b>\(name) to <b>\(price)</b>"
                }

                // Ovverride icon
                eventIcon.image = UIImage(named: "event-price-changed")

                meanfulchange = true
            }
        }

        if meanfulchange {
            return meainfulstr.htmlToAttributedString()
        } else {
            return "Updated details for <b>\(type)</b> named <b>\(name)".htmlToAttributedString()
        }
    }

    fileprivate func getNameFromChange(event: EstateEvent) -> String {
        // Assume the change is an assignement but still check for the right value
        // {"action": "assigned", "element": "estate", "assigned_to": 11}
        guard let change = event.change else {
            return "bug-no-change"
        }

        let json = JSON(parseJSON: change)

        if let name = json["name"].string {
            // Search for the user locally
            return name
        } else {
            return "no-name"
        }
    }

    fileprivate func getUserNameFromChange(event: EstateEvent) -> String {
        // Assume the change is an assignement but still check for the right value
        // {"action": "assigned", "element": "estate", "assigned_to": 11}
        guard let change = event.change else {
            return "bug-no-change"
        }

        let json = JSON(parseJSON: change)

        if let userId = json["assigned_to"].int64 {
            // Search for the user locally
            if let user = userService.findBy(id: userId) {
                return user.name ?? "User \(userId)"
            } else {
                return "User \(userId)"
            }

        } else {
            return "no-userid"
        }
    }

//    :estate_created => "estate_created",
//    :estate_deleted => "estate_deleted",
//    :estate_assigned => "estate_assigned",
//    :estate_unassigned => "estate_unassigned",
//    :estate_archived => "estate_archived",
//    :estate_open => "estate_open",
//    :estate_location_change => "estate_location_change",
//    :estate_image_added => "estate_image_added",
//    :estate_details_updated => "estate_details_updated"
    fileprivate func imageFor(changeType: String?) -> UIImage? {
        guard let changeType = changeType else {
            return nil
        }

        switch changeType {
        case "estate_created":
            return UIImage(named: "event-add-property")
        case "estate_deleted":
            return UIImage(named: "event-remove-property")
        case "estate_assigned":
            return UIImage(named: "event-assign")
        case "estate_unassigned":
            return UIImage(named: "event-unassign")
        case "estate_archived":
            return UIImage(named: "event-archived")
        case "estate_open":
            return UIImage(named: "event-open")
        case "estate_location_change":
            return UIImage(named: "event-location-change")
        case "estate_image_added":
            return UIImage(named: "event-image-added")
        case "estate_details_updated":
            return UIImage(named: "event-edit-property")
        default:
            // unknown
            return UIImage(named: "event-unknown")
        }
    }
}
