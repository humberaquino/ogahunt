//
//  SignUpView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

protocol SignUpViewDelegate: class {
    func signupAction(view: SignUpView, registration: RegisterRequest)
    func loginAction(view: SignUpView)
}

class SignUpView: UIView {
    var mainBg: UIImageView!

    var nameIcon: UIImageView!
    var emailIcon: UIImageView!
    var passwordIcon: UIImageView!

    var nameTextField: UITextField!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var passwordConfirmationTextField: UITextField!
    var loginButton: UIButton!

    var signupLabel: UILabel!
    var signupButton: UIButton!

    weak var delegate: SignUpViewDelegate?

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
        backgroundColor = .white

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        addGestureRecognizer(tapGesture)

        // Create & setup

//        mainIcon = UIImageView(image: UIImage(named: "mainLogo"))
        mainBg = UIImageView(image: UIImage(named: "signup-bg"))

        signupButton = UIButton(type: .system)
        signupButton.setTitle("Create my account", for: UIControl.State())
        signupButton.titleLabel?.font = UIFont(name: signupButton.titleLabel!.font.fontName, size: 22)
        signupButton.addTarget(self, action: #selector(signupButtonTapped(_:)), for: .touchUpInside)

        nameTextField = UITextField()
        nameTextField.placeholder = "Name"
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always

        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always

        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.keyboardType = UIKeyboardType.emailAddress

        passwordTextField = UITextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always

        passwordConfirmationTextField = UITextField()
        passwordConfirmationTextField.isSecureTextEntry = true
        passwordConfirmationTextField.placeholder = "Password confirmation"
        passwordConfirmationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordConfirmationTextField.leftViewMode = .always

        nameIcon = UIImageView(image: UIImage(named: "login.name")!.withRenderingMode(.alwaysTemplate))
        emailIcon = UIImageView(image: UIImage(named: "login.email")!.withRenderingMode(.alwaysTemplate))
        passwordIcon = UIImageView(image: UIImage(named: "login.password")!.withRenderingMode(.alwaysTemplate))

        signupLabel = UILabel()
        signupLabel.text = "Already have an account?"
        signupLabel.textAlignment = .right

        loginButton = UIButton(type: .system)
        loginButton.setTitle("Sign in", for: UIControl.State())
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)

        loginButton.sizeToFit()

        // Debug
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        nameTextField.setBottomBorder()
        passwordConfirmationTextField.setBottomBorder()

        nameIcon.tintColor = UIColor("#2EC4B6")
        emailIcon.tintColor = UIColor("#2EC4B6")
        passwordIcon.tintColor = UIColor("#2EC4B6")

//                signupButton.backgroundColor = .green
//                signupLabel.backgroundColor = .red

        // Add to view
        addSubview(emailIcon)
        addSubview(nameIcon)
        addSubview(passwordIcon)
        addSubview(mainBg)
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(passwordConfirmationTextField)
        addSubview(loginButton)
        addSubview(signupLabel)
        addSubview(signupButton)
    }

    func setupLayout() {
        let textFieldHeight = 40
        let controlMargin = 40

        let top = topMargin()

        // Layout
        mainBg.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(380)
        }

        nameIcon.snp.makeConstraints { make in
            make.top.equalTo(mainBg.snp.bottom).offset(30)
            make.left.equalTo(self.snp.left).offset(controlMargin)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        nameTextField.snp.makeConstraints { make in
            make.centerY.equalTo(nameIcon.snp.centerY)
            make.left.equalTo(nameIcon.snp.right).offset(10)
            make.right.equalTo(self.snp.right).offset(-controlMargin)
            make.height.equalTo(textFieldHeight)
        }

        emailIcon.snp.makeConstraints { make in
            make.top.equalTo(nameIcon.snp.bottom).offset(20)
            make.left.equalTo(nameIcon.snp.left)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        emailTextField.snp.makeConstraints { make in
            make.centerY.equalTo(emailIcon.snp.centerY)
            make.left.equalTo(nameTextField.snp.left)
            make.right.equalTo(nameTextField.snp.right)
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

        passwordConfirmationTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.left.equalTo(emailTextField.snp.left)
            make.right.equalTo(emailTextField.snp.right)
            make.height.equalTo(textFieldHeight)
        }

        signupButton.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmationTextField.snp.bottom).offset(30)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }

        var leftSignupOffset = 50
        var signupLabelBottomOffset = -30
        if DeviceLayout.isSmallDevice() {
            leftSignupOffset = 25
            signupLabelBottomOffset = -20
        }

        signupLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(leftSignupOffset)
            make.height.equalTo(20)
            make.width.equalTo(200)
            make.bottom.equalTo(self.snp.bottom).offset(signupLabelBottomOffset)
        }

        loginButton.snp.makeConstraints { make in
            make.left.equalTo(signupLabel.snp.right).offset(5)
            make.centerY.equalTo(signupLabel.snp.centerY)
        }
    }

    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        //        aTextField.resignFirstResponder()
        endEditing(true)
        restoreView()
    }

    func topMargin() -> CGFloat {
        var topMargin: CGFloat = 0
        let height = DeviceLayout.deviceHeight()
        if height <= 568 {
            topMargin = -130
        }
        return topMargin
    }

    func moveViewUpBy(amount: CGFloat) {
        let top = topMargin()
        mainBg.snp.remakeConstraints { make in
            make.top.equalTo(top).offset(-amount)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(380)
        }
    }

    func restoreView() {
        let top = topMargin()
        mainBg.snp.remakeConstraints { make in
            make.top.equalTo(top)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(380)
        }
    }

    // MARK: - Actions

    @objc
    func loginButtonTapped(_: Any) {
        delegate?.loginAction(view: self)
    }

    @objc
    func signupButtonTapped(_: Any) {
        let registerRequest = RegisterRequest.buildEmpty()
        registerRequest.confirmedPassword = passwordConfirmationTextField.text
        registerRequest.password = passwordTextField.text
        registerRequest.name = nameTextField.text
        registerRequest.email = emailTextField.text

        delegate?.signupAction(view: self, registration: registerRequest)
    }
}
