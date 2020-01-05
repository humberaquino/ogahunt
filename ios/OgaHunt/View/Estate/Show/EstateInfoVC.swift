//
//  EstateInfoVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import SnapKit
import UIKit

class EstateInfoVC: UIViewController {
    var estate: Estate!

    var latestPrice = UILabel()
    var estateType = UILabel()

    var address = UITextView()
    var addressTitle = UILabel()

    var details = UITextView()
    var detailsTitle = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            //            self.estateShowView = EstateShowView()
            self.reloadUI()
        }

        reloadUI()
    }

    func configWith(estate: Estate) {
        self.estate = estate
    }

    func reloadUI() {
        view.removeAllSubView()

        latestPrice = UILabel()
        estateType = UILabel()

        address = UITextView()

        addressTitle = UILabel()
        addressTitle.text = "Address"

        details = UITextView()
        detailsTitle = UILabel()
        detailsTitle.text = "Details"

        estateType.textColor = UIColor.darkGray
        estateType.textAlignment = .right
        estateType.font = UIFont.systemFont(ofSize: 12)

        addressTitle.textColor = UIColor.darkGray
        addressTitle.textAlignment = .left
        addressTitle.font = UIFont.systemFont(ofSize: 16)

        address.textAlignment = .left
        address.font = UIFont.systemFont(ofSize: 18)
        address.textContainerInset = .zero
        address.isUserInteractionEnabled = false
//        address.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

        latestPrice.textColor = UIColor.darkGray
        latestPrice.textAlignment = .right
        latestPrice.font = UIFont.systemFont(ofSize: 20)

        detailsTitle.textColor = UIColor.darkGray
        detailsTitle.textAlignment = .left
        detailsTitle.font = UIFont.systemFont(ofSize: 16)

        details.textAlignment = .left
        details.font = UIFont.systemFont(ofSize: 18)
        details.textContainerInset = .zero
        details.isUserInteractionEnabled = false
//        details.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

//        addressTitle.backgroundColor = UIColor.red
//        detailsTitle.backgroundColor = UIColor.red
//        address.backgroundColor = UIColor.yellow
//        details.backgroundColor = UIColor.blue

        view.addSubview(latestPrice)
        view.addSubview(estateType)

        view.addSubview(address)
        view.addSubview(addressTitle)

        view.addSubview(details)
        view.addSubview(detailsTitle)

        latestPrice.snp.makeConstraints { make in
            make.top.equalTo(55)
            make.right.equalTo(-5)
            make.height.equalTo(20)
            make.width.equalTo(150)
        }

        estateType.snp.makeConstraints { make in
            make.top.equalTo(latestPrice.snp.bottom).offset(5)
            make.right.equalTo(-5)
            make.height.equalTo(20)
            make.width.equalTo(75)
        }

        addressTitle.snp.makeConstraints { make in
            make.top.equalTo(latestPrice.snp.top)
            make.left.equalTo(5)
            make.height.equalTo(25)
            make.width.equalTo(80)
        }

        address.snp.makeConstraints { make in
            make.top.equalTo(addressTitle.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(5)
            make.height.equalTo(60)
            make.right.equalTo(estateType.snp.left).offset(3)
        }

        detailsTitle.snp.makeConstraints { make in
            make.top.equalTo(address.snp.bottom).offset(5)
            make.left.equalTo(5)
            make.height.equalTo(25)
            make.width.equalTo(80)
        }

        details.snp.makeConstraints { make in
            make.top.equalTo(detailsTitle.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(5)
            make.right.equalTo(self.view).offset(-5)
            make.height.equalTo(250)
        }

        if let estate = estate {
            estateType.text = estate.type // EstateType(rawValue: estate.type)?.asString()

            if estate.address != nil && estate.address != "" {
                address.text = estate.address
            } else {
                address.text = "No address"
                address.textColor = UIColor.lightGray
            }

            if estate.details != nil && estate.details != "" {
                details.text = estate.details
            } else {
                details.text = "No details"
                details.textColor = UIColor.lightGray
            }

            if let currentPrice = estate.currentPrice {
                if let price = CurrencyUtils.formattedLatestPrice(price: currentPrice) {
                    latestPrice.text = "$\(price)"
                } else {
                    latestPrice.text = "No price"
                    latestPrice.textColor = UIColor.lightGray
                }
            }
        }
    }
}
