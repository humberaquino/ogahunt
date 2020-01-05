//
//  UserListView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

class UserListView: UIView {
    let tableView = UITableView()

    convenience init() {
        self.init(frame: CGRect.zero)
        render()
    }

    func render() {
        backgroundColor = .white

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
    }

    func reloadData() {
        tableView.reloadData()
    }
}
