//
//  SettingsVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import AEConsole
import Eureka
import PKHUD
import UIKit
// import PinpointKit

class SettingsVC: FormViewController {
    var coreDataStack: CoreDataStack!

    let feedbackEmail = "feedback@ogahunt.com"

    let activityIndicator = UIActivityIndicatorView()
    var syncStartedFRomSettings = false
//    var pinpointKit: PinpointKit!

    override func viewDidLoad() {
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.setupUI()
        }

        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindow {
                if window.safeAreaInsets.bottom > 0 {
                    self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
                    self.navigationController?.navigationBar.prefersLargeTitles = true
                }
            }
        }

        setupUI()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        enableActivityIndicator(false)

        NotificationCenter.default.addObserver(self, selector: #selector(syncSuccess(notification:)), name: Notification.Name.syncSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncFailed(notification:)), name: Notification.Name.syncFailure, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncSkipped(notification:)), name: Notification.Name.syncSkipped, object: nil)
    }

    func setup(stack: CoreDataStack) {
        coreDataStack = stack
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFormValues()
    }

    func updateFormValues() {
        let authService = AuthService()
        let team = authService.currentTeam()
        let email = authService.email()

        if let emailRow = form.rowBy(tag: "email") as? TextRow {
            emailRow.value = email
        }

        if let nameRow = form.rowBy(tag: "name") as? TextRow {
            nameRow.value = team?.name
        }

        if let roleRow = form.rowBy(tag: "role") as? TextRow {
            roleRow.value = team?.role
        }
    }

    func setupUI() {
        form.removeAll()

        title = "Settings"

        form +++ Section("User")
            <<< TextRow { row in
                row.tag = "email"
                row.title = "Email"
                row.cell.isUserInteractionEnabled = false
            }
            <<< TextRow { row in
                row.tag = "role"
                row.title = "Role"
                row.cell.isUserInteractionEnabled = false
//                row.value = team?.role
            }
            <<< TextRow { row in
                row.tag = "name"
                row.title = "Name"
                row.cell.isUserInteractionEnabled = false
//                row.value = team?.name
            }

            +++ Section("Team")
            <<< ButtonRow {
                $0.title = "Contacts"
                $0.onCellSelection({ _, _ in
                    self.listContacts()
                })
            }
            <<< ButtonRow {
                $0.title = "Users"
                $0.onCellSelection({ _, _ in
                    self.listTeamMembers()
                })
            }
            <<< ButtonRow {
                $0.title = "Invitations"
                $0.onCellSelection({ _, _ in
                    self.listInvitedUsers()
                })
            }

            +++ Section("Account")
            <<< ButtonRow {
                $0.tag = "sync-button"
                $0.title = "Sync"
                $0.onCellSelection({ _, _ in
                    self.syncSettings()
                })
            }
            <<< ButtonRow {
                $0.title = "Logout"
                $0.onCellSelection({ _, _ in
                    self.logoutAction()
                })
            }
//            <<< ButtonRow {
//                $0.title = "Send feedback"
//                $0.onCellSelection({ _, _ in
//                    self.sendFeedback()
//                })
//            }

            +++ Section("Info")
            <<< TextRow { row in
                row.title = "Version"
                row.value = VersionUtils.currentVersion()
                row.cell.isUserInteractionEnabled = false
            }

        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(openConsole(_:)))
        longPressGR.minimumPressDuration = 2.5
        view.addGestureRecognizer(longPressGR)
    }

    @objc func openConsole(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            log.info("Toogle console")
            Console.shared.toggle()
        }
    }

    func sendFeedback() {
//        pinpointKit = PinpointKit(feedbackRecipients: [feedbackEmail])
//        pinpointKit.show(from: self)
//        BugReporting.invoke()
    }

    func logoutAction() {
        let authService = AuthService()
        authService.logout()
    }

    func listContacts() {
        SyncNotifier.fireContacsSync()

        let contactListVC = ContactListVC()
        contactListVC.setupWith(coreDataStack: coreDataStack, selectMode: false)
        navigationController?.pushViewController(contactListVC, animated: true)
    }

    func listTeamMembers() {
        SyncNotifier.fireTeamSync()

        let userListVC = UserListVC()
        userListVC.setupWith(coreDataStack: coreDataStack)
        userListVC.selectMode = false
        navigationController?.pushViewController(userListVC, animated: true)
    }

    func listInvitedUsers() {
        let userInvitationListVC = UserInvitationListVC()
        navigationController?.pushViewController(userInvitationListVC, animated: true)
    }

    func syncSettings() {
        disableSyncButton(true)
        enableActivityIndicator(true)
        syncStartedFRomSettings = true
        SyncNotifier.fireSync(force: true)
    }

    func disableSyncButton(_ disable: Condition) {
        if let syncRow = form.rowBy(tag: "sync-button") as? ButtonRow {
            syncRow.disabled = disable
            syncRow.evaluateDisabled()
        }
    }

    func enableActivityIndicator(_ enable: Bool) {
        if enable {
            activityIndicator.show()
            activityIndicator.startAnimating()
        } else {
            activityIndicator.hide()
            activityIndicator.stopAnimating()
        }
    }

    @objc func syncSuccess(notification _: NSNotification) {
        log.info("Sync success!")

        if syncStartedFRomSettings {
            HUD.flash(.success, delay: 1.0)
        }

//        gradientLoadingBar.hide()
        disableSyncButton(false)
        enableActivityIndicator(false)
        syncStartedFRomSettings = false
    }

    @objc func syncSkipped(notification _: NSNotification) {
        log.info("Sync skipped!")
//        gradientLoadingBar.hide()
        if syncStartedFRomSettings {
            HUD.flash(.labeledError(title: "Sync skipped", subtitle: "Can try to sync again in 10 secs"), delay: 2.5)
        }

        disableSyncButton(false)
        enableActivityIndicator(false)

        syncStartedFRomSettings = false
    }

    @objc func syncFailed(notification: NSNotification) {
        var errorMsg = "no-error"
        if let userInfo = notification.userInfo, let error = userInfo["error"] as? Error {
            errorMsg = error.localizedDescription
        }
        log.error("Sync failed: \(errorMsg)")
        disableSyncButton(false)
        enableActivityIndicator(false)

        if syncStartedFRomSettings {
            let alert = Alert.simple(title: "Sync failed", message: errorMsg)
            present(alert, animated: true, completion: nil)
            syncStartedFRomSettings = false
        }
    }
}
