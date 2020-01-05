//
//  EstateFormVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Eureka
import Foundation
import SwiftPhotoGallery
import UIKit

protocol EstateFormDetailsVCDelegate: class {
    func didSaveForm(estateResponse: EstateResponse)
    func didCancelForm()
}

class EstateFormDetailsVC: FormViewController {
    weak var delegate: EstateFormDetailsVCDelegate?

    var estateResponse: EstateResponse!
    var selectedContact: Contact?

    var coreDataStack: CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupWith(estateResponse: EstateResponse, stack: CoreDataStack) {
        self.estateResponse = estateResponse
        coreDataStack = stack
    }
}

extension EstateFormDetailsVC: UINavigationBarDelegate {
    func positionForBar(bar _: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// UI building
extension EstateFormDetailsVC {
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

        title = estateResponse.name
    }

    @objc func saveAction(_: Any) throws {
        log.info("Save")

        // Validate
        let validResults = try validateForm()

        if validResults.valid {
            fromViewToModel()
            delegate?.didSaveForm(estateResponse: estateResponse)
        } else {
            let alert = Alert.simple(title: "Validation failed", message: validResults.reason!)
            present(alert, animated: true, completion: nil)
        }
    }

    @objc func closeAction(_: Any) {
        delegate?.didCancelForm()
    }

    func validateForm() throws -> ValidationResult {
        guard let row: TextRow = form.rowBy(tag: "name") else { throw ValidationResultError.cantValidate(reason: "No name tag in detail form") }

        if let name = row.value {
            let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmedName.isEmpty {
                return ValidationResult(valid: false, reason: "Empty name provided")
            } else if trimmedName.count < Estate.Limits.MinNameCount {
                return ValidationResult(valid: false, reason: "Name should have at least \(Estate.Limits.MinNameCount) characters")
            } else if trimmedName.count > Estate.Limits.MaxNameCount {
                return ValidationResult(valid: false, reason: "Name should have no more than \(Estate.Limits.MinNameCount) characters")
            } else {
                return ValidationResult(valid: true, reason: nil)
            }
        } else {
            return ValidationResult(valid: false, reason: "No name provided")
        }
    }

    // swiftlint:disable function_body_length
    func setupForm() {
        form +++ Section("basic")
            <<< TextRow("name") { row in
                row.title = "Name"
                row.placeholder = "Add a name"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })
            <<< ActionSheetRow<String>("type") {
                $0.title = "Estate type"
                $0.selectorTitle = "Pick a type"
                $0.options = EstateType.allValues()
                $0.value = EstateType.defaultValue()
            }
            <<< TextRow("address") { row in
                row.title = "Address"
                row.placeholder = "Add an address"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })

            +++ Section("Main Contact") {
                $0.tag = "mainContact"
            }
            <<< TextRow("contactName") { row in
                row.title = "Name"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
                cell.textField.isUserInteractionEnabled = false
            })
            <<< TextRow("contactNumber") { row in
                row.title = "Number"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
                cell.textField.isUserInteractionEnabled = false
            })
            <<< ButtonRow("changeContact") { row in
                row.title = "Change contact"
                row.onCellSelection({ _, _ in
                    self.showSelectContact()
                })
            }

            +++ Section("contact") {
                $0.tag = "selectContact"
            }
            <<< ButtonRow("selectContact") { row in
                row.title = "Choose one"
                row.onCellSelection({ _, _ in
                    self.showSelectContact()
                })
            }

            +++ Section("price")
            <<< DecimalRow("price") { row in
                row.title = "Price"
                row.placeholder = "Set a price"
            }.cellSetup({ cell, _ in
                cell.textField.autocorrectionType = .no
            })

            +++ Section("details")
            <<< TextAreaRow("details") { row in
                row.title = "Details"
                row.placeholder = "General details"
            }

        navigationOptions = RowNavigationOptions.Disabled
    }

    func showSelectContact() {
        let contactList = ContactListVC()
        contactList.delegate = self
        contactList.setupWith(coreDataStack: coreDataStack)
        contactList.popOnSave = true
        contactList.selectedContact = selectedContact
        navigationController?.pushViewController(contactList, animated: true)
    }
}

extension EstateFormDetailsVC: ContactListVCDelegate {
    func didSelect(contact: Contact) {
        // Update view
        selectedContact = contact
        formContactToView()
//
        navigationController?.popViewController(animated: true)
    }
}

// Validation and transformation
extension EstateFormDetailsVC {
    func valudateBasicRequirements() -> ValidationResult {
        return ValidationResult(valid: true, reason: nil)
    }

    func formContactToView() {
        var contact: Contact?

        if selectedContact != nil {
            contact = selectedContact
        } else {
            if let contactId = estateResponse.mainContact?.id {
                let contactService = ContactService(managedObjectContext: coreDataStack.managedContext)
                if let foundContact = contactService.findBy(id: contactId) {
                    contact = foundContact
                    selectedContact = contact
                }
            }
        }

        if let mainContact = contact {
            if let row: TextRow = form.rowBy(tag: "contactName") {
                row.value = mainContact.fullname()
            }

            if let row: TextRow = form.rowBy(tag: "contactNumber") {
                row.value = mainContact.phone1
            }

            if let contactSection = form.sectionBy(tag: "mainContact") {
                contactSection.hidden = false
                contactSection.evaluateHidden()
            }

            if let selectContact = form.sectionBy(tag: "selectContact") {
                selectContact.hidden = true
                selectContact.evaluateHidden()
            }
        } else {
            if let contactSection = form.sectionBy(tag: "mainContact") {
                contactSection.hidden = true
                contactSection.evaluateHidden()
            }

            if let selectContact = form.sectionBy(tag: "selectContact") {
                selectContact.hidden = false
                selectContact.evaluateHidden()
            }
        }

        // Refresh
        tableView.reloadData()
    }

    func fromModelToView() {
        if let estate = estateResponse {
            if let row: TextRow = form.rowBy(tag: "name") {
                row.value = estate.name
            }

            if let row: ActionSheetRow<String> = form.rowBy(tag: "type"),
                let type = estate.type {
                row.value = type
            }

            if let row: TextRow = form.rowBy(tag: "address") {
                row.value = estate.address
            }

            if let row: TextAreaRow = form.rowBy(tag: "details") {
                row.value = estate.details
            }

            formContactToView()

            if let row: DecimalRow = form.rowBy(tag: "price"),
                let price = estate.currentPrice,
                let amount = price.amount {
                let value = Double(string: amount)
//                let dec = Decimal(string: amount)
                row.value = value
            }
        }

        tableView.reloadData()
    }

    // swiftlint:disable cyclomatic_complexity
    func fromViewToModel() {
        if let row: TextRow = form.rowBy(tag: "name") {
            estateResponse.name = row.value ?? ""
        }

        if let row: ActionSheetRow<String> = form.rowBy(tag: "type") {
            estateResponse.type = row.value
        }

        if let row: TextRow = form.rowBy(tag: "address") {
            estateResponse.address = row.value ?? ""
        }

        if let row: TextAreaRow = form.rowBy(tag: "details") {
            estateResponse.details = row.value ?? ""
        }

        // Contact
        if let selectedContact = selectedContact {
            estateResponse.mainContact = selectedContact.buildContactResponse()
//            estate.mainContact = selectedContact
        }

        // Price
        if let row: DecimalRow = form.rowBy(tag: "price") {
            if let value = row.value {
//                let valuePrice = Decimal(value)

                if let price = PriceResponse.buildEmpty() {
                    price.amount = String(format: "%.2f", value)
                    price.currency = "USD" // HArdcoded for now. TODO: FIXME!
                    estateResponse.currentPrice = price
                }

//                    estateResponse.currentPrice =
//
//                    // Value changed
//                    let newPrice = Price(context: coreDataStack.managedContext)
//                    newPrice.createdAt = NSDate()
//                    newPrice.amount = NSDecimalNumber(decimal: valuePrice)
//                    estate.addToPrices(newPrice)
//                    estate.currentPrice = newPrice
            }

            // If price changed then append
//            if let price = estate.latestPrice() {
//                if let value = row.value {
//                    let valuePrice = Decimal(value)
//
//                    if price.amount != nil && (price.amount?.decimalValue != valuePrice) {
//                        // Value changed
//                        let newPrice = Price(context: coreDataStack.managedContext)
//                        newPrice.createdAt = NSDate()
//                        newPrice.amount = NSDecimalNumber(decimal: valuePrice)
//                        estate.addToPrices(newPrice)
//                        estate.currentPrice = newPrice
//                    }
//                }
//            } else {
//                // No price yet
//                if let value = row.value {
//                    let valuePrice = Decimal(value)
//                    // A value and not price yet, let's save
//                    let newPrice = Price(context: coreDataStack.managedContext)
//                    newPrice.createdAt = NSDate()
//                    newPrice.amount = NSDecimalNumber(decimal: valuePrice)
//                    newPrice.notes = "Initial price"
//                    estate.addToPrices(newPrice)
//                    estate.currentPrice = newPrice
//                }
//            }
        }
    }
}
