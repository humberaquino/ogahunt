//
//  ContactViewCell.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

class ContactViewCell: UITableViewCell {
    let name = UILabel()
    let address = UILabel()
    let estateType = UILabel()
    let mainImage = UIImageView()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
    }

    func render() {
        backgroundColor = .white
        name.textColor = .black

        estateType.textColor = UIColor.darkGray
        estateType.textAlignment = .right
        estateType.font = UIFont.systemFont(ofSize: 12)

        address.textColor = UIColor.darkGray
        address.textAlignment = .left
        address.font = UIFont.systemFont(ofSize: 13)

        mainImage.contentMode = .scaleAspectFill
        mainImage.clipsToBounds = true

        addSubview(name)
        addSubview(mainImage)
        addSubview(estateType)
        addSubview(address)

        mainImage.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }

        name.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.left.equalTo(mainImage.snp.right).offset(5)
            make.top.equalTo(mainImage.snp.top).offset(4)
        }

        address.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.left.equalTo(name.snp.left)
            make.top.equalTo(name.snp.bottom).offset(5)
        }

        estateType.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.right.equalTo(self).offset(-8)
            make.top.equalTo(name.snp.top)
        }
    }
}

extension ContactViewCell {
    func populate(with estate: Estate) {
        name.text = estate.name
        address.text = estate.address
        estateType.text = estate.type

        if let image = estate.keyImage() {
            mainImage.image = image
        }
    }
}
