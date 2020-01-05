//
//  LoginVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import PKHUD
import Promises
import UIKit

class SignInVC: BaseAuthVC {
    static func presentIfRequired(controller: UIViewController?, animated: Bool = false) {
        let authService = AuthService()
        let requiresLogin = authService.requiresLogin()
        if requiresLogin {
            let loginVC = SignInVC()
            let nvc = UINavigationController(rootViewController: loginVC)
            nvc.modalPresentationStyle = .fullScreen
            controller?.present(nvc, animated: animated, completion: nil)
        }
    }

    var loginView = SignInView()
    var authAPI: AuthAPI!

    // model
    var email: String?
    var token: String?
    var userId: Int64?

    override func viewDidLoad() {
        super.viewDidLoad()
        authAPI = AuthAPI(backend: Backend.global)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    let raiseWithKeyboard: CGFloat = DeviceLayout.baseKeyboardRiseHeight()

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
//                view.frame.origin.y -= raiseWithKeyboard

                loginView.moveViewUpBy(amount: raiseWithKeyboard)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
//                view.frame.origin.y += raiseWithKeyboard

                loginView.restoreView()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // To fix a mislayout change
        loginView.restoreView()
    }

    override func setupUI() {
        loginView = SignInView()
        loginView.delegate = self
        view = loginView

        // PReload with email if exisitng
        loginView.emailTextField.text = authService.email()

        // Register sync observers
        NotificationCenter.default.addObserver(self, selector: #selector(syncSuccess(notification:)), name: Notification.Name.syncSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncFailed(notification:)), name: Notification.Name.syncFailure, object: nil)
    }

    @objc func syncSuccess(notification _: NSNotification) {
        log.info("Sync success!")
        HUD.flash(.success, delay: 1.0)
        HUD.hide()
        dismiss(animated: true, completion: nil)
    }

    @objc func syncFailed(notification: NSNotification) {
        var errorMsg = "no-error"
        if let userInfo = notification.userInfo, let error = userInfo["error"] as? Error {
            errorMsg = error.localizedDescription
        }
        log.error("Sync failed: \(errorMsg)")
        HUD.show(.error)
        HUD.hide(afterDelay: 2.0)
    }
}

extension SignInVC: SignInViewDelegate {
    func invalidForm(view _: SignInView, email _: String, password _: String, reason: String) {
        let alert = Alert.simple(title: "Incomplete sign in", message: reason)
        present(alert, animated: true, completion: nil)
    }

    func loginAction(view _: SignInView, email: String, password: String) {
        loginView.endEditing(true)
        loginView.restoreView()

        HUD.show(.progress)

        // Call the API
        authAPI.signin(email: email, password: password).then { authResponse in

            if authResponse.success == true {
                guard let token = authResponse.token else {
                    let alert = Alert.simple(title: "Sign in error", message: "Access token not provided.\nPlease contact us about this situation")
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                guard let userId = authResponse.userId else {
                    let alert = Alert.simple(title: "Sign in error", message: "User id not provided.\nPlease contact us about this situation")
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                // Store email and token
                self.email = email
                self.token = token
                self.userId = userId

                let teams = authResponse.teams ?? []
                if teams.isEmpty {
                    let alert = Alert.simple(title: "Signin problem", message: "It looks like you are not part of a team.\nPlease contact the team owner")
                    self.present(alert, animated: true, completion: nil)
                    return
                } else if teams.count == 1 {
                    let defaultTeam = teams.first!
                    self.selectTeam(teamResponse: defaultTeam)
                } else {
                    // more then one team. Present team selection
                    HUD.hide(animated: true)
                    let teamSelectVC = TeamSelectVC()
                    teamSelectVC.setup(teams: teams, delegate: self)
                    self.present(UINavigationController(rootViewController: teamSelectVC), animated: true, completion: nil)
                }
            } else {
                HUD.show(.error)
                HUD.hide()

                let details = authResponse.errors ?? ""
                let alert = Alert.simple(title: "Sign in failed", message: "\(details)")
                self.present(alert, animated: true, completion: nil)
            }

        }.catch { error in
            HUD.show(.error)
            HUD.hide()

            let msg = self.extractErrorMsg(error: error)

            let alert = Alert.simple(title: "Sign in error", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func selectTeam(teamResponse: TeamInfoResponse) {
        guard let team = teamResponse.toTeam() else {
            let alert = Alert.simple(title: "Signin problem", message: "It looks like your team config has issues.\nPlease contact the team owner")
            present(alert, animated: true, completion: nil)
            return
        }

        // Check if we should clean

        // Email changed or team changed
        if let currentEmail = self.authService.email() {
            if currentEmail != email {
                log.info("Email changed: Cleaning core data!")
                SyncMaster.global.coreDataStack.clearCoreData()
            } else {
                // Same email. now check if team changed
                if let currentTeam = self.authService.currentTeam(), currentTeam.id != team.id {
                    log.info("Team changed: Cleaning core data!")
                    SyncMaster.global.coreDataStack.clearCoreData()
                }
            }
        }

        // Store credentials
        authService.saveSuccessAuth(userId: userId!, email: email!, apiToken: token!, team: team)

//        Crashlytics.sharedInstance().setObjectValue("\(team.name) (ID: \(team.id)", forKey: "team")
//        Crashlytics.sharedInstance().setUserEmail(email)
//        Crashlytics.sharedInstance().setObjectValue(team.role, forKey: "role")
//        Crashlytics.sharedInstance().setUserIdentifier("\()")

        // Start a full sync
        HUD.show(.label("Sync in progress"))
        SyncNotifier.fireSync(force: true)
    }

    func extractErrorMsg(error: Error) -> String {
        if let error = error as? SigninError {
            switch error {
            case let .failedRequest(cause):
                return cause
            case let .invalidJSON(responseBody):
                return responseBody
            case let .invalidRequest(cause):
                return cause
            case .invalidResponseValue:
                return "Response is empty"
            }
        } else {
            return error.localizedDescription
        }
    }

    func signupAction(view _: SignInView) {
        print("Flip to signup")

        let signupVC = SignUpVC()
        signupVC.delegate = self
        navigationController?.pushViewController(signupVC, animated: true)
    }
}

extension SignInVC: TeamSelectVCDelegate {
    func didSelect(team: TeamInfoResponse) {
        dismiss(animated: true, completion: nil)
        selectTeam(teamResponse: team)
    }
}

extension SignInVC: SignUpVCDelegate {
    func didRegisterSuccessfully(registration: RegisterRequest) {
        // Fill view
        loginView.updateViewWith(email: registration.email, password: registration.password)
        navigationController?.popViewController(animated: true)
    }
}
