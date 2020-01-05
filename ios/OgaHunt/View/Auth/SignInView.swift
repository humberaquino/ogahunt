//
//  LoginView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

protocol SignInViewDelegate: class {
    func loginAction(view: SignInView, email: String, password: String)
    func signupAction(view: SignInView)
    func invalidForm(view: SignInView, email: String, password: String, reason: String)
}

class SignInView: UIView {
//    var mainIcon: UIImageView!
    var mainBg: UIImageView!

    var emailIcon: UIImageView!
    var passwordIcon: UIImageView!

    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!

    var signupLabel: UILabel!
    var signupButton: UIButton!

    weak var delegate: SignInViewDelegate?

    let mainIconSize = 380

    convenience init() {
        self.init(frame: CGRect.zero)
        render()
    }

    func render() {
        setupControls()
        setupLayout()
    }

    // MARK: - Setup

    func setupControls() {
        backgroundColor = UIColor("#FFFFFF")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        addGestureRecognizer(tapGesture)

        // Create & setup

//        mainIcon = UIImageView(image: UIImage(named: "mainLogo"))
//        mainIcon.layer.cornerRadius = 7.0
//        mainIcon.clipsToBounds = true
        mainBg = UIImageView(image: UIImage(named: "signin-bg"))

        loginButton = UIButton(type: .system)
        loginButton.setTitle("Sign in", for: UIControl.State())
        loginButton.titleLabel?.font = UIFont(name: loginButton.titleLabel!.font.fontName, size: 22)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)

        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.setBottomBorder()

        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.clearButtonMode = .whileEditing

        passwordTextField = UITextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.setBottomBorder()

        emailIcon = UIImageView(image: UIImage(named: "login.email")!.withRenderingMode(.alwaysTemplate))
        emailIcon.tintColor = UIColor("#2EC4B6")
        passwordIcon = UIImageView(image: UIImage(named: "login.password")!.withRenderingMode(.alwaysTemplate))
        passwordIcon.tintColor = UIColor("#2EC4B6")

        signupLabel = UILabel()
        signupLabel.text = "Don't have an account?"
        signupLabel.textAlignment = .right

        signupButton = UIButton(type: .system)
        signupButton.setTitle("Create one", for: UIControl.State())
        signupButton.addTarget(self, action: #selector(signupButtonTapped(_:)), for: .touchUpInside)

        signupButton.sizeToFit()

        // Debug
//        emailTextField.backgroundColor = .lightGray
//        passwordTextField.backgroundColor = .lightGray

//        signupButton.backgroundColor = .green
//        signupLabel.backgroundColor = .red

        // Add to view
        addSubview(mainBg)
        addSubview(emailIcon)
        addSubview(passwordIcon)
//        addSubview(mainIcon)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(signupLabel)
        addSubview(signupButton)
    }

    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
//        aTextField.resignFirstResponder()
        endEditing(true)
        restoreView()
    }

    func setupLayout() {
        let textFieldHeight = 40
        let controlMargin = 40

        let top = DeviceLayout.topMargin()

        mainBg.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(mainIconSize)
        }

        emailIcon.snp.makeConstraints { make in
            make.top.equalTo(mainBg.snp.bottom).offset(30)
            make.left.equalTo(self.snp.left).offset(controlMargin)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        emailTextField.snp.makeConstraints { make in
            make.centerY.equalTo(emailIcon.snp.centerY)
            make.left.equalTo(emailIcon.snp.right).offset(10)
            make.right.equalTo(self.snp.right).offset(-controlMargin)
            make.height.equalTo(textFieldHeight)
        }

        passwordIcon.snp.makeConstraints { make in
            make.top.equalTo(emailIcon.snp.bottom).offset(20)
            make.left.equalTo(emailIcon.snp.left)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        passwordTextField.snp.makeConstraints { make in
            make.centerY.equalTo(passwordIcon.snp.centerY)
            make.left.equalTo(emailTextField.snp.left)
            make.right.equalTo(emailTextField.snp.right)
            make.height.equalTo(textFieldHeight)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }

        var leftSignupOffset = 30
        var signupLabelBottomOffset = -30
        if DeviceLayout.isSmallDevice() {
            leftSignupOffset = 15
            signupLabelBottomOffset = -20
        }

        signupLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(leftSignupOffset)
            make.height.equalTo(20)
            make.width.equalTo(200)
            make.bottom.equalTo(self.snp.bottom).offset(signupLabelBottomOffset)
        }

        signupButton.snp.makeConstraints { make in
            make.left.equalTo(signupLabel.snp.right).offset(5)
            make.centerY.equalTo(signupLabel.snp.centerY)
        }
    }

    func moveViewUpBy(amount: CGFloat) {
        let top = DeviceLayout.topMargin()
        mainBg.snp.remakeConstraints { make in
            make.top.equalTo(top).offset(-amount)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(mainIconSize)
        }
    }

    func restoreView() {
        let top = DeviceLayout.topMargin()
        mainBg.snp.remakeConstraints { make in
            make.top.equalTo(top)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(mainIconSize)
        }
    }

    func processForm() -> LoginFormProcessResult {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let emptyEmail = email.isEmpty
        let emptyPassword = password.isEmpty

        if emptyEmail && emptyPassword {
            return LoginFormProcessResult(valid: false, reason: "Please provide an email and a password", email: email, password: password)
        } else if emptyEmail {
            return LoginFormProcessResult(valid: false, reason: "No email provided", email: email, password: password)
        } else if emptyPassword {
            return LoginFormProcessResult(valid: false, reason: "No password provided", email: email, password: password)
        }

        return LoginFormProcessResult(valid: true, email: email, password: password)
    }

    func updateViewWith(email: String?, password: String?) {
        emailTextField.text = email
        passwordTextField.text = password
    }

    // MARK: - Actions

    @objc
    func loginButtonTapped(_: Any) {
        let result = processForm()
        if !result.valid {
            delegate?.invalidForm(view: self, email: result.email, password: result.password, reason: result.reason)
            return
        }

        delegate?.loginAction(view: self, email: result.email, password: result.password)
    }

    @objc
    func signupButtonTapped(_: Any) {
        delegate?.signupAction(view: self)
    }
}

extension UITextField {
    func setBottomBorder() {
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor("#D9D9D9").cgColor // very light grey
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
    }
}

extension SignInView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

struct LoginFormProcessResult {
    let valid: Bool
    let reason: String
    let email: String
    let password: String

    init(valid: Bool, email: String, password: String) {
        self.valid = valid
        self.email = email
        self.password = password
        reason = ""
    }

    init(valid: Bool, reason: String, email: String, password: String) {
        self.valid = valid
        self.reason = reason
        self.email = email
        self.password = password
    }
}
