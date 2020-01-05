//
//  EventMainView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class EstateEventsView: UIView {
    let tableView = UITableView()

    convenience init() {
        self.init(frame: CGRect.zero)
        render()
    }

    func render() {
        tableView.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 11)

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
