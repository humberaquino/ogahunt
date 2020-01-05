//
//  ContactListVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/12/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
// import UIEmptyState
import PKHUD
import UIKit

protocol ContactListVCDelegate: class {
    func didSelect(contact: Contact)
}

class ContactListVC: UIViewController {
    // Select mode: When on the list is selectable and assumes a delegate

    // Constants
    let contactCellIdentifier = "ContactCellIdentifier"

    // Persistence
    var coreDataStack: CoreDataStack!

    // View
    var contactListView = ContactListView()

    var emptyListView: SimpleActionableView!

    var selectedContact: Contact?
    var editingContact: Contact?

    var selectMode = true
    var popOnSave = false

    var contactAPI: ContactAPI!

    weak var delegate: ContactListVCDelegate?

    lazy var fetchedResultsController: NSFetchedResultsController<Contact> = {
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Contact.lastName),
                                    ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

        contactAPI = ContactAPI(backend: Backend.global)

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkEmptyView()
//        reloadEmptyStateForTableView(contactListView.tableView)
    }

//    func setupWith(estate: Estate, coreDataStack: CoreDataStack) {
//        self.estate = estate
//        selectedContact = self.estate.mainContact
//        self.coreDataStack = coreDataStack
    ////        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
//    }

    func setupWith(coreDataStack: CoreDataStack, selectMode: Bool = true) {
        self.coreDataStack = coreDataStack
        self.selectMode = selectMode
//        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
    }

//    func reloadEstateModels() {
//        contactListView.reloadData()
//    }

    @objc func addContact(_: Any) {
        addContactAction()
    }

    func addContactAction() {
        let contactForm = ContactFormVC()
        contactForm.delegate = self
        navigationController?.pushViewController(contactForm, animated: true)
    }

    func checkEmptyView() {
        if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            emptyListView.show()
        } else {
            emptyListView.hide()
        }
    }
}

// Data Source
extension ContactListVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        //        return estateResults?.count ?? 0
        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
        return objects.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier)
        // ?? UITableViewCell(style: .subtitle, reuseIdentifier: contactCellIdentifier)

        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: contactCellIdentifier)
        configure(cell: cell, for: indexPath)
        return cell
    }

    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let contact = fetchedResultsController.object(at: indexPath)

        if selectMode {
            // Add a check mark to the selected one
            if let selectedContact = self.selectedContact,
                selectedContact.objectID == contact.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        cell.textLabel?.text = contact.fullname()
        if let phone1 = contact.phone1 {
            cell.detailTextLabel?.text = "Phone: \(phone1)"
        }
    }
}

extension ContactListVC: ContactFormVCDelegate {
    func didSaveContact(contactForm: ContactResponse, controller: ContactFormVC) {
        if let editingContact = self.editingContact, editingContact.alreadySaved {
            // Call update endpoint
            log.debug("Updating contact")

            guard let teamId = Backend.global.currentTeam()?.id else {
                // TODO: Show error and reset
                print("Error! no teamId defined")
                return
            }

            HUD.show(.label("Updating contact"), onView: view)

            // Call rest
            contactAPI.updateContact(teamId: teamId, contactResponse: contactForm).then { result in
                // Save locally

                let contactService = ContactService(managedObjectContext: self.coreDataStack.managedContext)
                try contactService.merge(contact: editingContact, contactResponse: result)

//                let contact = Contact(context: self.coreDataStack.managedContext)
//                self.selectedContact = contact

                // Use response to update entity's values
//                contact.merge(contactResponse: result)

                self.saveContextAndDismiss()
                self.editingContact = nil
                HUD.hide()

                if self.popOnSave {
                    self.delegate?.didSelect(contact: editingContact)
                    self.navigationController?.popViewController(animated: true)
                }

            }.catch { error in
                HUD.show(.labeledError(title: "Save error", subtitle: error.localizedDescription))
                HUD.hide(afterDelay: 2.0)
                controller.enableSaveButton()
            }

        } else {
            log.debug("Save contact")
            guard let teamId = Backend.global.currentTeam()?.id else {
                // TODO: Show error and reset
                print("Error! no teamId defined")
                return
            }

            HUD.show(.label("Saving contact"), onView: view)

            // Call rest
            contactAPI.saveContact(teamId: teamId, contactResponse: contactForm).then { result in
                // Save locally

                let contact = Contact(context: self.coreDataStack.managedContext)
                self.selectedContact = contact

                // Use response to update entity's values
                contact.merge(contactResponse: result)

                self.saveContextAndDismiss()
                HUD.hide()

                if self.popOnSave {
                    self.delegate?.didSelect(contact: contact)
                    self.navigationController?.popViewController(animated: true)
                }

            }.catch { error in
                HUD.show(.labeledError(title: "Save error", subtitle: error.localizedDescription))
                HUD.hide(afterDelay: 2.0)
                controller.enableSaveButton()
            }
        }
    }

    func saveContextAndDismiss() {
        coreDataStack.saveContext()
        contactListView.reloadData()
        navigationController?.popViewController(animated: true)
    }

    func didCancelSaveContact() {
        print("Cancel contact save")
        editingContact = nil
        navigationController?.popViewController(animated: true)
    }
}

// Table view Delegate
extension ContactListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = fetchedResultsController.object(at: indexPath)
        delegate?.didSelect(contact: contact)
    }

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let contact = fetchedResultsController.object(at: indexPath)

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { _, _ in
            // delete item at indexPath

            // Open contact
            let contactForm = ContactFormVC()
            contactForm.delegate = self

            let form = contact.buildContactResponse()

            contactForm.setupWith(contactForm: form)

            self.editingContact = contact
            self.navigationController?.pushViewController(contactForm, animated: true)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { _, _ in
            // delete item at indexPath

            let action = UIAlertController(title: "Delete contact?", message: nil, preferredStyle: .alert)
            action.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.handleDeleteContact(contact)
            }))

            action.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in

            }))

            self.present(action, animated: true, completion: nil)
        }

        return [edit, delete]
    }

    func handleDeleteContact(_ contact: Contact) {
        log.info("Delete contact")

        HUD.show(.label("Deleting contact..."))

        let contactSyncAction = ContactSyncAction(queue: .main, backend: Backend.global, context: coreDataStack.managedContext)
        contactSyncAction.deleteContactRemotelly(contact: contact).then { result in

            if result.success {
                HUD.flash(.success, delay: 0.5)
                log.info("Contact \(contact.id) deleted")
            } else {
                HUD.hide()
                let reason = result.reason ?? "It is associated to other estates. Please deassociate it from all of them be able to delete it"
                let alert = Alert.simple(title: "Can't delete contact", message: reason)
                self.present(alert, animated: true, completion: nil)
            }

            self.checkEmptyView()
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Delete failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 55
    }
}

extension ContactListVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        contactListView.tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            contactListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            contactListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if let cell = contactListView.tableView.cellForRow(at: indexPath!) {
                configure(cell: cell, for: indexPath!)
            }
        case .move:
            contactListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            contactListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        contactListView.tableView.endUpdates()
    }
}

// Empty estate list
extension ContactListVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupContactList()
        setupEmptyTableView()
    }

    func setupBase() {
        view = contactListView
    }

    func setupTopBar() {
        title = "Contact"
        // Tab bar
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupContactList() {
        contactListView.tableView.dataSource = self
        contactListView.tableView.delegate = self
        contactListView.tableView.register(EstateViewCell.self, forCellReuseIdentifier: contactCellIdentifier)
    }
}

extension ContactListVC: SimpleActionableViewDelegate {
    func didTappedActionButton(view _: SimpleActionableView) {
        log.info("Add contact")
        addContactAction()
    }

    func setupEmptyTableView() {
        contactListView.tableView.tableFooterView = UIView(frame: CGRect.zero)

        let image = UIImage(named: "empty-contact-list")!
        let title = "No contacts found"
        let description = "Please add one"
        let actionTitle = "Add contact"

        emptyListView = SimpleActionableView(image: image, title: title, description: description, actionTitle: actionTitle)
        emptyListView.setup(view: view, delegate: self)
    }
}
