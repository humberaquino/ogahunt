//
//  EstateListItemView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import Kingfisher
import SnapKit
import UIKit

class EstateViewCell: UITableViewCell {
    let name = UILabel()
    let address = UITextView()
    let estateType = UILabel()
    let lastPrice = UILabel()
    let mainImage = UIImageView()

    let contactIcon = UIImageView()
    let locationIcon = UIImageView()

    let assignedTo = UILabel()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
    }

    func render() {
        
        estateType.textColor = UIColor.darkGray
        estateType.textAlignment = .right
        estateType.font = UIFont.systemFont(ofSize: 10)
        
        address.textColor = UIColor.darkGray
        address.textAlignment = .left
        address.font = UIFont.systemFont(ofSize: 14)
        address.isUserInteractionEnabled = false
       
        // Removes internal padding of the text
        address.textContainerInset = .zero
        address.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

        lastPrice.textAlignment = .right
        lastPrice.font = UIFont.systemFont(ofSize: 18)

        mainImage.contentMode = .scaleAspectFill
        mainImage.clipsToBounds = true

        mainImage.layer.cornerRadius = 7.0

        assignedTo.textColor = UIColor.darkGray
        assignedTo.textAlignment = .right
        assignedTo.font = UIFont.systemFont(ofSize: 10)

        if let theme = AppAppearance.current {
            address.backgroundColor = .clear
            lastPrice.textColor = theme.tableViewCellPrice
        }

        addSubview(name)
        addSubview(mainImage)
        addSubview(estateType)
        addSubview(address)
        addSubview(lastPrice)
        addSubview(contactIcon)
        addSubview(locationIcon)
        addSubview(assignedTo)

        estateType.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.right.equalTo(self).offset(-8)
            make.top.equalTo(self).offset(5)
        }

        mainImage.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }

        name.snp.makeConstraints { make in
            make.left.equalTo(mainImage.snp.right).offset(5)
            make.top.equalTo(mainImage.snp.top).offset(4)
            make.right.equalTo(estateType.snp.left)
            make.height.equalTo(20)
        }

        // has contact, has location
        locationIcon.snp.makeConstraints { make in
            make.left.equalTo(mainImage.snp.right).offset(5)
            make.bottom.equalTo(self).offset(-5)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }

        contactIcon.snp.makeConstraints { make in
            make.left.equalTo(locationIcon.snp.right).offset(5)
            make.bottom.equalTo(locationIcon)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }

        lastPrice.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-8)
            make.left.equalTo(contactIcon.snp.right).offset(-5)
            make.bottom.equalTo(self).offset(0)
            make.height.equalTo(30)
        }

        address.snp.makeConstraints { make in
            make.left.equalTo(name.snp.left)
            make.top.equalTo(name.snp.bottom).offset(5)
            make.right.equalTo(estateType.snp.left)
            make.bottom.equalTo(locationIcon.snp.top)
        }

        assignedTo.snp.makeConstraints { make in
            make.right.equalTo(estateType.snp.right)
            make.bottom.equalTo(lastPrice.snp.top).offset(5)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
    }
}

extension EstateViewCell {
    func populate(with estate: Estate) {
        name.text = estate.name
        address.text = estate.address

        estateType.text = estate.type

        if let assignedUser = estate.assignedTo {
            assignedTo.text = assignedUser.name
        }

        contactIcon.image = UIImage(named: "contact-icon")

        locationIcon.image = UIImage(named: "map-pin-icon")

        if let theme = AppAppearance.current {
            if estate.mainContact != nil {
                contactIcon.tintColor = theme.tableViewActiveIcon
            } else {
                contactIcon.tintColor = theme.tableViewDisabledIcon
            }

            if estate.location != nil {
                locationIcon.tintColor = theme.tableViewActiveIcon
            } else {
                locationIcon.tintColor = theme.tableViewDisabledIcon
            }
        }

        if let currentPrice = estate.currentPrice {
            if let price = CurrencyUtils.formattedLatestPrice(price: currentPrice) {
                lastPrice.text = "$\(price)"
            } else {
                lastPrice.text = "No price"
                lastPrice.textColor = UIColor.lightGray
            }
        }

        populateImage(estate: estate)
    }

    fileprivate func populateImage(estate: Estate) {
        // Check for buggy image
        guard let images = estate.images?.array as? [Image] else {
            let image = UIImage(named: "bug-image")
            mainImage.image = image
            return
        }

        // Empty images
        guard let firstImage = images.first else {
            let image = UIImage(named: "no-image")
            mainImage.image = image
            return
        }

        // check if there is an image that needs to get downloaded

        if estate.hasImageNeedingDownload() {
            SyncNotifier.downloadEstateImages(estateId: estate.id)
        }

        // 1. Check local path first. Use it if it exists, otherwise trigger an image load
        guard let path = firstImage.localPath else {
            if let imageURL = firstImage.imageURL {
                let image = UIImage(named: "loading")

                if let url = URL(string: imageURL), url.scheme != nil {
                    mainImage.kf.setImage(with: url, placeholder: image)
                } else {
                    mainImage.image = image
                }
            } else {
                // No image url either. Error
                let image = UIImage(named: "bug-image")
                mainImage.image = image
            }
            return
        }

        // Get the local saved file
        let dataManager = DataManager()
        if let image = dataManager.imageFrom(string: path) {
            // Show the stored image
            mainImage.image = image
        } else {
            let image = UIImage(named: "bug-image")
            mainImage.image = image
        }
    }
}
