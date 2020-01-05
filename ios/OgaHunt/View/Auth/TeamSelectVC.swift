//
//  TeamSelectVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import PKHUD
import UIKit

protocol TeamSelectVCDelegate: class {
    func didSelect(team: TeamInfoResponse)
}

class TeamSelectVC: UIViewController {
    // Select mode: When on the list is selectable and assumes a delegate

    // Constants
    let teamSelectCellIdentifier = "TeamSelectCellIdentifier"

    // Persistence
    var coreDataStack: CoreDataStack!

    // View
    var contactListView = ContactListView()
    let tableView = UITableView()

    var teams: [TeamInfoResponse] = []

    var selectMode = true

    var contactAPI: ContactAPI!

    weak var delegate: TeamSelectVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setup(teams: [TeamInfoResponse], delegate: TeamSelectVCDelegate) {
        self.delegate = delegate
        self.teams = teams
    }
}

// Data Source
extension TeamSelectVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return teams.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: teamSelectCellIdentifier)
        // ?? UITableViewCell(style: .subtitle, reuseIdentifier: teamSelectCellIdentifier)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: teamSelectCellIdentifier)

        let team = teams[indexPath.row]

        cell.textLabel?.text = team.name
        cell.detailTextLabel?.text = team.role

        return cell
    }
}

// Table view Delegate
extension TeamSelectVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let team = teams[indexPath.row]
        delegate?.didSelect(team: team)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 44
    }
}

// Empty estate list
extension TeamSelectVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupTableList()
        setupEmptyTableView()
    }

    func setupBase() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
    }

    func setupTopBar() {
        title = "Select a team"
        // Tab bar
//        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(sele(_:)))
//        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupTableList() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EstateViewCell.self, forCellReuseIdentifier: teamSelectCellIdentifier)
    }

    func setupEmptyTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}
