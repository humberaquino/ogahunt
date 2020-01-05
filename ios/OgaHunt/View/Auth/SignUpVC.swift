//
//  SignUpVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import PKHUD
import UIKit

protocol SignUpVCDelegate: class {
    func didRegisterSuccessfully(registration: RegisterRequest)
}

class SignUpVC: BaseAuthVC {
    var signUpView = SignUpView()
//    let authService = AuthService()
    var authAPI: AuthAPI!

    weak var delegate: SignUpVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Add an extra 100 because the form is longer
    let raiseWithKeyboard: CGFloat = 100 + DeviceLayout.baseKeyboardRiseHeight()

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                signUpView.moveViewUpBy(amount: raiseWithKeyboard)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                signUpView.restoreView()
            }
        }
    }

    override func setupUI() {
        signUpView = SignUpView()
        signUpView.delegate = self
        view = signUpView

        authAPI = AuthAPI(backend: Backend.global)
    }
}

extension SignUpVC: SignUpViewDelegate {
    func signupAction(view _: SignUpView, registration: RegisterRequest) {
        // Validate new user

        signUpView.endEditing(true)
        signUpView.restoreView()

        HUD.show(.label("Registering.."))

        let validationResults = validateRegistration(registration)

        if !validationResults.valid {
            HUD.hide()
            let alert = Alert.simple(title: "Validation failed", message: validationResults.reason ?? "no-reason")
            present(alert, animated: true, completion: nil)
            return
        }

        // Request to do a signup
        authAPI.register(registration: registration).then { result in

            if let success = result.success, success {
                HUD.hide(animated: true)
//                HUD.flash(.label("Success!"), delay: 0.5)

                let alert = Alert.simpleOk(title: "Successful registration!", message: "Please check your email to activate your account :)") {
                    self.delegate?.didRegisterSuccessfully(registration: registration)
                }
                self.present(alert, animated: true, completion: nil)

            } else {
                HUD.hide()
                let alert = Alert.simple(title: "Registration failed", message: result.message ?? "no-message")
                self.present(alert, animated: true, completion: nil)
            }

        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Registration error", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func loginAction(view _: SignUpView) {
        navigationController?.popViewController(animated: true)
    }
}

extension SignUpVC {
    func validateRegistration(_ registration: RegisterRequest) -> ValidationResult {
        guard let email = registration.email else {
            return ValidationResult(valid: false, reason: "No email provided")
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if !trimmedEmail.isValidEmailAddress() {
            return ValidationResult(valid: false, reason: "Invalid email address")
        }

        guard let password = registration.password else {
            return ValidationResult(valid: false, reason: "No password provided")
        }

        guard let confirmationPassword = registration.confirmedPassword else {
            return ValidationResult(valid: false, reason: "No password confirmation provided")
        }

        guard registration.name != nil else {
            return ValidationResult(valid: false, reason: "No name provided")
        }

        if password != confirmationPassword {
            return ValidationResult(valid: false, reason: "Passwords don't match")
        }

        return ValidationResult(valid: true, reason: nil)
    }
}
