//
//  EstateMainContactVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class EstateContactVC: UIViewController {
    var estate: Estate!

    var fullname = UILabel()
    var fullnameTitle = UILabel()

    var mobilePhone = UILabel()
    var mobilePhoneTitle = UILabel()

    var otherPhone = UILabel()
    var otherPhoneTitle = UILabel()

    var noContactLabel = UILabel()

    var phoneNumberGR: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.reloadUI()
        }

        reloadUI()
    }

    func configWith(estate: Estate) {
        self.estate = estate
    }

    fileprivate func styleForVerticalDescription(title: UILabel, description: UILabel) {
        title.textColor = UIColor.darkGray
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16)

        description.textAlignment = .left
        description.font = UIFont.systemFont(ofSize: 18)
    }

    fileprivate func reloadNoContactUI() {
        noContactLabel = UILabel()
        noContactLabel.text = "No contact selected 👀"
        noContactLabel.textColor = UIColor.darkGray
        noContactLabel.textAlignment = .center
        noContactLabel.font = UIFont.systemFont(ofSize: 16)

        view.addSubview(noContactLabel)

        noContactLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(20)
            make.width.equalTo(200)
        }
    }

    fileprivate func reloadContactUI(_ mainContact: Contact) {
        fullnameTitle = UILabel()
        fullname = UILabel()
        mobilePhoneTitle = UILabel()
        mobilePhone = UILabel()
        otherPhoneTitle = UILabel()
        otherPhone = UILabel()

        // Default style
        styleForVerticalDescription(title: fullnameTitle, description: fullname)
        styleForVerticalDescription(title: mobilePhoneTitle, description: mobilePhone)
        styleForVerticalDescription(title: otherPhoneTitle, description: otherPhone)

        fullnameTitle.text = "Name"
        let name = mainContact.fullname()
        if name == Contact.NoName {
            fullname.text = "No name"
            fullname.textColor = UIColor.lightGray
        } else {
            fullname.text = name
        }

        mobilePhoneTitle.text = "Main phone"
        if mainContact.phone1 != nil && mainContact.phone1 != "" {
            mobilePhone.text = PhoneNumberUtils.format(number: mainContact.phone1)
        } else {
            mobilePhone.text = "No main phone"
            mobilePhone.textColor = UIColor.lightGray
        }

        otherPhoneTitle.text = "Extra phone"
        if mainContact.phone2 != nil && mainContact.phone2 != "" {
            otherPhone.text = PhoneNumberUtils.format(number: mainContact.phone2)
        } else {
            otherPhone.text = "No extra phone"
            otherPhone.textColor = UIColor.lightGray
        }

        phoneNumberGR = UITapGestureRecognizer(target: self, action: #selector(phoneNumberTapped(_:)))
        phoneNumberGR.delegate = self
        mobilePhone.isUserInteractionEnabled = true
        mobilePhone.addGestureRecognizer(phoneNumberGR)

        view.addSubview(fullnameTitle)
        view.addSubview(mobilePhoneTitle)
        view.addSubview(otherPhoneTitle)
        view.addSubview(fullname)
        view.addSubview(mobilePhone)
        view.addSubview(otherPhone)

        fullnameTitle.snp.makeConstraints { make in
            make.top.equalTo(55)
            make.left.equalTo(self.view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(20)
        }

        fullname.snp.makeConstraints { make in
            make.top.equalTo(fullnameTitle.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(10)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-5)
        }

        mobilePhoneTitle.snp.makeConstraints { make in
            make.top.equalTo(fullname.snp.bottom).offset(15)
            make.left.equalTo(self.view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(20)
        }

        mobilePhone.snp.makeConstraints { make in
            make.top.equalTo(mobilePhoneTitle.snp.bottom)
            make.left.equalTo(self.view).offset(10)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-5)
        }

        otherPhoneTitle.snp.makeConstraints { make in
            make.top.equalTo(mobilePhone.snp.bottom).offset(15)
            make.left.equalTo(self.view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(20)
        }

        otherPhone.snp.makeConstraints { make in
            make.top.equalTo(otherPhoneTitle.snp.bottom)
            make.left.equalTo(self.view).offset(10)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-5)
        }
    }

    func reloadUI() {
        view.removeAllSubView()

        if let mainContact = estate.mainContact {
            reloadContactUI(mainContact)
        } else {
            reloadNoContactUI()
        }
    }

    @objc func phoneNumberTapped(_: Any) {
        // Ask to confirm
        if let phoneNumber = estate.mainContact?.phone1 {
            guard let number = URL(string: "tel://" + phoneNumber) else { return }
            UIApplication.shared.open(number)
        }
    }
}

extension EstateContactVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
