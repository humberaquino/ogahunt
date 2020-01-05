//
//  UserInvitationListVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import DateToolsSwift
import PKHUD
import Promises
import UIKit

class UserInvitationListVC: UIViewController {
    let userInvitationCellIdentifier = "userInvitationCellIdentifier"

    var userInvites: [UserInviteResponse] = []
    var userInticationView = UserInvitationListView()

    var teamAPI: TeamAPI!

    var emptyListView: SimpleActionableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        teamAPI = TeamAPI(backend: Backend.global)
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Trigger upload
        refreshInvitationList()
        checkEmptyView()
    }

    func reloadData() {
        userInticationView.tableView.reloadData()
    }

    func checkEmptyView() {
        if userInvites.isEmpty {
            emptyListView.show()
        } else {
            emptyListView.hide()
        }
    }

    func refreshInvitationList() {
        HUD.show(.label("Getting invitations.."))

        guard let teamId = Backend.global.currentTeam()?.id else {
            // TODO: Show error and reset
            print("Error! no teamId defined")
            HUD.hide()
            return
        }

        teamAPI.fetchUserInvitations(teamId: teamId).then { invitationList in
            HUD.hide(animated: true)
            if let invitations = invitationList.invitations {
                self.userInvites = invitations
            }
            self.reloadData()
            self.checkEmptyView()
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Failed to fetch invitations", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UserInvitationListVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupUserList()
        setupEmptyTableView()
    }

    func setupBase() {
        view = userInticationView
    }

    func setupTopBar() {
        title = "Invitations"

        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(inviteUserAction(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupUserList() {
        userInticationView.tableView.dataSource = self
        userInticationView.tableView.delegate = self
        userInticationView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: userInvitationCellIdentifier)
    }

    @objc func inviteUserAction(_: Any) {
        inviteUser()
    }

    func inviteUser() {
        let alert = UIAlertController(title: "Send invitate to:", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Email address"
        })

        alert.addAction(UIAlertAction(title: "Send invite", style: .default, handler: { _ in
            guard let email = alert.textFields?.first?.text else {
                let alert = Alert.simple(title: "Can't send invitation", message: "Email not provided")
                self.present(alert, animated: true, completion: nil)
                return
            }

            if !email.isValidEmailAddress() {
                let alert = Alert.simple(title: "Failed to send invitation", message: "Email provided is invalid")
                self.present(alert, animated: true, completion: nil)
                return
            }

            self.sendInvitationTo(email: email)

        }))

        present(alert, animated: true)
    }

    func sendInvitationTo(email: String) {
        HUD.show(.label("Sending invitation..."))

        guard let teamId = Backend.global.currentTeam()?.id else {
            // TODO: Show error and reset
            print("Error! no teamId defined")
            HUD.hide()
            return
        }

        teamAPI.sendUserInvitation(teamId: teamId, email: email).then { _ in
//            HUD.hide(animated: true)

            self.refreshInvitationList()

        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Failed to fetch invitations", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UserInvitationListVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return userInvites.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: userInvitationCellIdentifier)

        configure(cell: cell, for: indexPath)
        return cell
    }

    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let userInvite = userInvites[indexPath.row]

        var status = "Pending"
        if let inviteAccepted = userInvite.inviteAccepted, inviteAccepted {
            if let inviteAcceptedAt = userInvite.inviteAcceptedAt {
                status = "Accepted - \(inviteAcceptedAt.timeAgoSinceNow)"
            } else {
                status = "Accepted"
            }
        } else {
            if let expiredAt = userInvite.inviteExpiresAt {
                if expiredAt.toMillis() < Date().toMillis() {
                    // expired
                    status = "Expired - \(expiredAt.timeAgoSinceNow)"
                } else {
                    status = "Pending - Expires in \(expiredAt.shortTimeAgoSinceNow)"
                }
            } else {
                status = "Pending"
            }
        }

        cell.textLabel?.text = userInvite.email
        cell.detailTextLabel?.text = status
    }
}

extension UserInvitationListVC: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        print("Seleted")
//        tableView.deselectRow(at: indexPath, animated: true)
//        let user = fetchedResultsController.object(at: indexPath)
//        delegate?.didSelect(estate: selectedEstate, user: user)
    }

    //    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let edit = UITableViewRowAction(style: .normal, title: "Edit") { _, indexPath in
    //            // delete item at indexPath
    //
    //            let contact = self.fetchedResultsController.object(at: indexPath)
    //            // Open contact
    //            let contactForm = ContactFormVC()
    //            contactForm.delegate = self
    //
    //            guard let form = contact.buildContactResponse() else {
    //                print("Opp. Can't build contact response")
    //                return
    //            }
    //
    //            contactForm.setupWith(contactForm: form)
    //
    //            self.editingContact = contact
    //            self.navigationController?.pushViewController(contactForm, animated: true)
    //        }
    //
    //        return [edit]
    //    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 55
    }
}

extension UserInvitationListVC: SimpleActionableViewDelegate {
    func didTappedActionButton(view _: SimpleActionableView) {
        log.info("Send invitation")
        inviteUser()
    }

    func setupEmptyTableView() {
        userInticationView.tableView.tableFooterView = UIView(frame: CGRect.zero)

        let image = UIImage(named: "empty-invitations-list")!
        let title = "No invitations found"
        let description = "You can send invitation from here. We'll send them an invite via email to join your OgaHunt team"
        let actionTitle = "Send invite"

        emptyListView = SimpleActionableView(image: image, title: title, description: description, actionTitle: actionTitle)
        emptyListView.setup(view: view, delegate: self)
    }
}
