//
//  ContactFormVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Eureka
import UIKit

protocol ContactFormVCDelegate: class {
    func didSaveContact(contactForm: ContactResponse, controller: ContactFormVC)
    func didCancelSaveContact()
}

class ContactFormVC: FormViewController {
    weak var delegate: ContactFormVCDelegate?
    var contactForm: ContactResponse?

    var showAddButtonOnEmpty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupWith(contactForm: ContactResponse) {
        self.contactForm = contactForm
    }

    func reloadUI() {
        fromModelToView()
    }

    func setupUI() {
        setupTopBar()
        setupForm()
        fromModelToView()
    }

    func setupTopBar() {
        // Add close modal button
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction(_:)))
        navigationItem.rightBarButtonItem = rightBarButton

        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeAction(_:)))
        navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func saveAction(_: Any) {
        // Disable right away to avoid multiple taps going through
        disableSaveButton()

        log.info("Save")
        if contactForm == nil {
            contactForm = ContactResponse.buildEmpty()
        }

        updateFromView(contactform: contactForm!)

        let validation = contactForm!.validate()

        if !validation.valid {
            let alert = Alert.simple(title: "Validation failed", message: validation.reason!)
            present(alert, animated: true, completion: nil)
            enableSaveButton()
        } else {
            delegate?.didSaveContact(contactForm: contactForm!, controller: self)
        }
    }

    func enableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func disableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    @objc func closeAction(_: Any) {
        delegate?.didCancelSaveContact()
    }

    func setupForm() {
        form +++ Section("basic")
            <<< TextRow("firstName") { row in
                row.title = "First Name"
                row.placeholder = "Add a name"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })
            <<< TextRow("lastName") { row in
                row.title = "Last Name"
                row.placeholder = "Add an address"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })

            +++ Section("Phones") {
                $0.tag = "phones"
            }
            <<< TextRow("mobilePhone") { row in
                row.title = "Phone 1"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })
            <<< TextRow("anotherPhone") { row in
                row.title = "Phone 2"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })

        navigationOptions = RowNavigationOptions.Disabled
    }

    func updateFromView(contactform: ContactResponse) {
        if let row: TextRow = form.rowBy(tag: "firstName") {
            contactform.firstName = row.value ?? ""
        }

        if let row: TextRow = form.rowBy(tag: "lastName") {
            contactform.lastName = row.value ?? ""
        }

        if let row: TextRow = form.rowBy(tag: "mobilePhone") {
            contactform.phone1 = row.value ?? ""
        }

        if let row: TextRow = form.rowBy(tag: "anotherPhone") {
            contactform.phone2 = row.value ?? ""
        }
    }

    func fromModelToView() {
        if let row: TextRow = form.rowBy(tag: "firstName") {
            row.value = contactForm?.firstName
        }

        if let row: TextRow = form.rowBy(tag: "lastName") {
            row.value = contactForm?.lastName
        }

        if let row: TextRow = form.rowBy(tag: "mobilePhone") {
            row.value = contactForm?.phone1
        }

        if let row: TextRow = form.rowBy(tag: "anotherPhone") {
            row.value = contactForm?.phone2
        }
    }
}
