//
//  UserListVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import PKHUD
import UIKit

protocol UserListVCDelegate: class {
    func didSelect(estate: Estate?, user: User)
}

class UserListVC: UIViewController {
    // Select mode: When on the list is selectable and assumes a delegate

    // Constants
    let userCellIdentifier = "UserCellIdentifier"

    // Persistence
    var coreDataStack: CoreDataStack!

    // View
    var userListView = UserListView()

    var myEmail: String?

    // Service
    //    var estateService: EstateService!
    //    var estate: Estate!

    var selectedUser: User?
    var selectedEstate: Estate?
    var editingUser: User?

    var selectMode = true

    var contactAPI: ContactAPI!

    weak var delegate: UserListVCDelegate?

    lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(User.name),
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

        myEmail = AuthService().email()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupWith(coreDataStack: CoreDataStack, delegate: UserListVCDelegate? = nil) {
        self.coreDataStack = coreDataStack
        self.delegate = delegate
    }

    @objc func inviteUser(_: Any) {
        // TODO:
        print("Invite user")
//        let contactForm = ContactFormVC()
//        contactForm.delegate = self
//        navigationController?.pushViewController(contactForm, animated: true)
    }
}

// Empty estate list
extension UserListVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupUserList()
        setupEmptyTableView()
    }

    func setupBase() {
        view = userListView
    }

    func setupTopBar() {
        title = "User"
        // Tab bar
        //        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact(_:)))
        //        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupUserList() {
        userListView.tableView.dataSource = self
        userListView.tableView.delegate = self
        userListView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: userCellIdentifier)
    }

    func setupEmptyTableView() {
        userListView.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}

// Data Source
extension UserListVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        //        return estateResults?.count ?? 0
        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
        return objects.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier, for: indexPath)
//        let cell = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier)
        // ?? UITableViewCell(style: .subtitle, reuseIdentifier: userCellIdentifier)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: userCellIdentifier)

        configure(cell: cell, for: indexPath)
        return cell
    }

    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let user = fetchedResultsController.object(at: indexPath)

        if selectMode {
            // Add a check mark to the selected one
            if let selectedUser = self.selectedUser,
                selectedUser.objectID == user.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        var name: String?

        if let myEmail = myEmail, myEmail == user.email {
            name = "(me) \(user.name ?? "")"
        } else {
            name = user.name
        }

        cell.textLabel?.text = name
        cell.detailTextLabel?.text = user.email
    }
}

// extension ContactListVC: ContactFormVCDelegate {
//    func didSaveContact(contactForm: ContactResponse) {
//        print("save contact")
//
//        // show HUD
//        HUD.show(.label("Saving contact"), onView: view)
//
//        if let editingContact = self.editingContact, editingContact.alreadySaved {
//            // Call update endpoint
//            //            contact = editingContact
//            self.editingContact = nil
//
//            saveContextAndDismiss()
//
//        } else {
//            guard let teamId = Backend.global.currentTeam()?.id else {
//                // TODO: Show error and reset
//                print("Error! no teamId defined")
//                return
//            }
//            // Call rest
//            contactAPI.saveContact(teamId: teamId, contactResponse: contactForm).then { result in
//                // Save locally
//
//                let contact = Contact(context: self.coreDataStack.managedContext)
//                self.selectedContact = contact
//
//                // Use response to update entity's values
//                contact.merge(contactResponse: result)
//
//                self.saveContextAndDismiss()
//                HUD.hide()
//
//                }.catch { error in
//                    HUD.show(.labeledError(title: "Save error", subtitle: error.localizedDescription))
//                    HUD.hide(afterDelay: 2.0)
//            }
//        }
//    }
//
//    func saveContextAndDismiss() {
//        coreDataStack.saveContext()
//        contactListView.reloadData()
//        navigationController?.popViewController(animated: true)
//    }
//
//    func didCancelSaveContact() {
//        print("Cancel contact save")
//        editingContact = nil
//        navigationController?.popViewController(animated: true)
//    }
// }

// Table view Delegate
extension UserListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = fetchedResultsController.object(at: indexPath)
        delegate?.didSelect(estate: selectedEstate, user: user)
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

extension UserListVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        userListView.tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            userListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            userListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if let cell = userListView.tableView.cellForRow(at: indexPath!) {
                configure(cell: cell, for: indexPath!)
            }
        case .move:
            userListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            userListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        userListView.tableView.endUpdates()
    }
}
