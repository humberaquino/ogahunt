//
//  EstateListVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import PKHUD
import Promises
import SnapKit
import UIKit

class EstateListVC: BaseManagedViewController {
    // Constants
    let estateCellIdentifier = "EstateCellIdentifier"

    var isRefreshing = false
    var observersConfigured = false

    var lastRefresh: Int64 = 0
    let refreshThresholdMillis: Int64 = 5 * 1000 // 5 secs

    private let refreshControl = UIRefreshControl()

    // Persistence
    var coreDataStack: CoreDataStack!

    // View
    var estateListView: EstateListView!

    // Service
    var estateService: EstateService!
    var estateFilter: EstateFilter?

    var filterModel = EstateFilterModel()

    var isAssignedTo = false

    var emptyListView: SimpleActionableView!

    var fetchedResultsController: NSFetchedResultsController<Estate>!

    func buildFetchedResultsController() -> NSFetchedResultsController<Estate> {
        let fetchRequest: NSFetchRequest<Estate> = Estate.fetchRequest()

        // Filter by
        fetchRequest.predicate = predicateFromFilter(filter: filterModel)

        // Sort & Order by
        let sort = sortPredicateFromFilter(filter: filterModel)
        fetchRequest.sortDescriptors = [sort]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }

    func reloadAndFetchResults() {
        fetchedResultsController = buildFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    func predicateFromFilter(filter: EstateFilterModel) -> NSPredicate {
        var basicPredicate = NSPredicate(format: "assignedTo == nil")
        if isAssignedTo {
            basicPredicate = NSPredicate(format: "assignedTo != nil")
        }

        if filter.listOnly == EstateFilterListOnly.all {
            return basicPredicate
        } else if filter.listOnly == EstateFilterListOnly.open {
            // Open only
            let openOnlyPredicate = NSPredicate(format: "status == %@", EstateFilterListOnly.open.rawValue)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [basicPredicate, openOnlyPredicate])
        } else {
            // Archived only
            let archivedOnlyPredicate = NSPredicate(format: "status == %@", EstateFilterListOnly.archived.rawValue)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [basicPredicate, archivedOnlyPredicate])
        }
    }

    func sortPredicateFromFilter(filter: EstateFilterModel) -> NSSortDescriptor {
        let isAsc = filter.sortOrder == SortOrder.asc

        // Sort by
        var key = #keyPath(Estate.createdAt)
        if filter.sortBy == EstateFilterSortBy.updatedAt {
            key = #keyPath(Estate.updatedAt)
        } else if filter.sortBy == EstateFilterSortBy.name {
            key = #keyPath(Estate.name)
        }

        return NSSortDescriptor(key: key, ascending: isAsc)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Solves refresh flickering
        // Ref: https://stackoverflow.com/a/55342111/223228
        extendedLayoutIncludesOpaqueBars = true

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.setupUI()
            self.reloadEstateModels()
        }

        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindow {
                if window.safeAreaInsets.bottom > 0 {
                    self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
                    self.navigationController?.navigationBar.prefersLargeTitles = true
                }
            }
        }

        reloadAndFetchResults()
        setupUI()

        setupObservers()
    }

    func setupObservers() {
        if observersConfigured {
            log.warning("Obsevers already configured!")
            return
        }
        observersConfigured = true
        NotificationCenter.default.addObserver(self, selector: #selector(syncSuccess(notification:)), name: Notification.Name.syncSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncFailed(notification:)), name: Notification.Name.syncFailure, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imagesDownloaded(notification:)),
                                               name: Notification.Name.syncImagesDownloaded, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didSaveContext), name: .NSManagedObjectContextDidSave, object: nil)
    }

    @objc func didSaveContext(notification: Notification) {
        guard let sender = notification.object as? NSManagedObjectContext else { return }

        if sender === coreDataStack.managedContext {
            print("main")
        } else {
            DispatchQueue.main.async {
                self.coreDataStack.managedContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }

    @objc func syncSuccess(notification _: NSNotification) {
        log.info("[\(isAssignedTo ? "Hunting view" : "Hunt List view")] Sync success notification received!")

        stopEstateSync()
        reloadAndFetchResults()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.reloadEstateModels()
        }
    }

    @objc func imagesDownloaded(notification _: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.reloadEstateModels()
        }
    }

    @objc func syncFailed(notification: NSNotification) {
        var errorMsg = "no-error"
        if let userInfo = notification.userInfo, let error = userInfo["error"] as? Error {
            errorMsg = error.localizedDescription
        }
        log.error("Sync failed: \(errorMsg)")

        stopEstateSync()
        reloadEstateModels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Check last time it ran. Get if necesary
//        reloadAndFetchResults()
        reloadEstateModels()
    }

    func setup(title: String, isAssignedTo: Bool, stack: CoreDataStack) {
        self.title = title
        self.isAssignedTo = isAssignedTo
        coreDataStack = stack
        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
    }

    func reloadEstateModels() {
//        coreDataStack.managedContext.mergeChanges(fromContextDidSave: <#T##Notification#>)
        estateListView.reloadData()
        checkEmptyView()
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
extension EstateListVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        //        return estateResults?.count ?? 0
        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
        return objects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: estateCellIdentifier, for: indexPath) as! EstateViewCell
        // swiftlint:enable force_cast

        configure(cell: cell, for: indexPath)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 110
    }

    func configure(cell: EstateViewCell, for indexPath: IndexPath) {
        let estate = fetchedResultsController.object(at: indexPath)
//        cell.delegate = self
        cell.populate(with: estate)
    }
}

// extension EstateListVC: EstateViewCellDelegate {
//    func requestImageDownload(estate: Estate) {
//
//        SyncNotifier.fireEstateSync()
//    }
// }

// Table view Delegate
extension EstateListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let estate = fetchedResultsController.object(at: indexPath)
        // Present a Estate list view
        let estateShowVC = EstateShowVC()
        estateShowVC.setupWith(estate: estate, stack: coreDataStack)
        navigationController?.pushViewController(estateShowVC, animated: true)
    }

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            let estate = self.fetchedResultsController.object(at: indexPath)

            let estateName = estate.name ?? "\(estate.id)"
            let alert = UIAlertController(title: "Delete estate", message: "Are you sure you want to delete estate '\(estateName)'?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.deleteEstate(estate: estate)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }

        let selectedEstate = fetchedResultsController.object(at: indexPath)

        let archiveActionName = selectedEstate.possibleArchiveAction()
        let archiveAction = UITableViewRowAction(style: .default, title: archiveActionName) { _, indexPath in

            let estate = self.fetchedResultsController.object(at: indexPath)
            self.toogleArchiveEstate(estate: estate)
//            do {
//                try self.estateService.toggleArchive(estate: estate)
//            } catch {
//                // FIXME: Imporve
//                print(error)
//            }
        }

        let assignmentActionName = selectedEstate.possibleAssignAction()
        let assignmentAction = UITableViewRowAction(style: .default, title: assignmentActionName) { _, _ in

            if assignmentActionName == "Assign" {
                let userListVC = UserListVC()
                userListVC.setupWith(coreDataStack: self.coreDataStack, delegate: self)
                userListVC.selectedEstate = selectedEstate
                self.navigationController?.pushViewController(userListVC, animated: true)
            } else {
                // Just call the unassign stuff
                self.unassign(estate: selectedEstate)
            }
        }

        // Assign colors
        if let current = AppAppearance.current {
//            deleteAction.backgroundColor = current.tableViewDeleteBg
//            deleteAction.image = UIImage(named: "trash")
            assignmentAction.backgroundColor = current.tableViewAssignBg
            archiveAction.backgroundColor = current.tableViewArchiveBg
        }

        return [assignmentAction, archiveAction, deleteAction]
    }

//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (context: UIContextualAction, view: UIView, success: (Bool) -> Void) in
//            // Call edit action
//
//            // Reset state
//            success(true)
//        })
//
//        deleteAction.image = UIImage(named: "trash")
//        if let current = AppAppearance.current {
//            deleteAction.backgroundColor = current.tableViewDeleteBg
//        }
//
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }

    func unassign(estate: Estate) {
        HUD.show(.label("Unassigning..."))
        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncher.unassignEstate(estate: estate).then { _ in
            HUD.flash(.success, delay: 0.5)
            self.checkEmptyView()
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Assignment failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func deleteEstate(estate: Estate) {
        HUD.show(.label("Deleting estate..."))

        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncher.deleteEstateRemotelly(estate: estate).then { _ in
            HUD.flash(.success, delay: 0.5)
            log.info("Estate \(estate.id) deleted")
            self.checkEmptyView()
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Delete failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func toogleArchiveEstate(estate: Estate) {
        if estate.status == Estate.Status.Archived {
            HUD.show(.label("Opening estate..."))
        } else {
            HUD.show(.label("Archiving estate..."))
        }

        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncher.toogleEstateRemotelly(estate: estate).then { newStatus in
            HUD.flash(.success, delay: 0.5)

//            let status = newEstate.status ?? "unknown"

            log.info("Estate \(estate.id) \(newStatus)ed")
            self.checkEmptyView()
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Change state failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension EstateListVC: UserListVCDelegate {
    func didSelect(estate: Estate?, user: User) {
        print("User selected: \(user)")
        guard let estate = estate else {
            // TODO: Notify about this
            print("Opps! This is a bug. No estate provided")
            return
        }

        HUD.show(.label("Assigning estate..."))
        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncher.assignEstate(estate: estate, to: user).then { _ in
            HUD.flash(.success, delay: 0.5)

            self.navigationController?.popViewController(animated: true)
        }.catch { error in
            HUD.hide()
            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Assignment failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension EstateListVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        estateListView.tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            estateListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            estateListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if let cell = estateListView.tableView.cellForRow(at: indexPath!) as? EstateViewCell {
                configure(cell: cell, for: indexPath!)
            } else {
                log.warning("Unwrapped cell not of type EstateViewCell at \(indexPath!)")
            }
        case .move:
            estateListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            estateListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        estateListView.tableView.endUpdates()
//        reloadEmptyStateForTableView(estateListView.tableView)
    }
}

// Tab bar delegate
extension EstateListVC: UITabBarDelegate {
    func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
        print("Selected: \(item.tag)")
    }
}

// Empty estate list
extension EstateListVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupEstateList()
        setupEmptyTableView()
    }

    func setupBase() {
        estateListView = EstateListView()
        estateListView.tableView.tableFooterView = UIView(frame: CGRect.zero)
        view = estateListView
    }

    func setupTopBar() {
        title = titleFromFilter()

        // Filter button

        let filterButton = UIBarButtonItem(image: UIImage(named: "filter-hunts"),
                                           style: UIBarButtonItem.Style.plain,
                                           target: self,
                                           action: #selector(openFilterMenu(_:)))

        let mapButton = UIBarButtonItem(image: UIImage(named: "map-pin"),
                                        style: UIBarButtonItem.Style.plain,
                                        target: self,
                                        action: #selector(openMapList(_:)))

        navigationItem.rightBarButtonItems = [filterButton, mapButton]
    }

    @objc func openFilterMenu(_: Any) {
        print("Open filter menu")

        let filterVC = EstateFilterMenuVC()
        filterVC.setup(filterModel: filterModel, delegate: self)
        present(UINavigationController(rootViewController: filterVC), animated: true, completion: nil)
    }

    @objc func openMapList(_: Any) {
        guard let estates = fetchedResultsController.fetchedObjects else {
            showNoLocationAlert()
            return
        }

        if !hasAtLeastOneLocation(estates) {
            showNoLocationAlert()
            return
        }

        let mapListVC = EstateMapListVC()
        mapListVC.setup(stack: coreDataStack, estates: estates)
        navigationController?.pushViewController(mapListVC, animated: true)
    }

    func showNoLocationAlert() {
        let alert = Alert.simple(title: "Empty map", message: "There are no locations to show")
        present(alert, animated: true, completion: nil)
    }

    func hasAtLeastOneLocation(_ estates: [Estate]) -> Bool {
        if estates.isEmpty {
            return false
        }

        var hasAtLeastOneLoc = false

        estates.forEach { estate in
            if estate.location != nil {
                hasAtLeastOneLoc = true
            }
        }

        return hasAtLeastOneLoc
    }

    fileprivate func setupRefreshControlFor(tableView: UITableView) {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing, please wait")
         
        refreshControl.addTarget(self, action: #selector(refreshEstateData(_:)), for: .valueChanged)
        
        if #available(iOS 13.0, *) {
            refreshControl.overrideUserInterfaceStyle  = .light
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    func setupEstateList() {
        estateListView.tableView.dataSource = self
        estateListView.tableView.delegate = self
        estateListView.tableView.register(EstateViewCell.self, forCellReuseIdentifier: estateCellIdentifier)

        setupRefreshControlFor(tableView: estateListView.tableView)
    }

    @objc private func refreshEstateData(_: Any) {
        startEstateSync()
    }

    func titleFromFilter() -> String {
        guard let estateFilter = estateFilter else {
            return title ?? ""
        }

        return "\(estateFilter.value.capitalized) list"
    }

    func startEstateSync() {
        if isRefreshing {
            print("Skip. Currently running")
            return
        }

        isRefreshing = true

        // Start refresh: show like pull-to refresh and disable button
        refreshControl.beginRefreshing()
        emptyListView.enableRefresh(enable: false)

        // Fire estate sync only
        SyncNotifier.fireEstateSync(force: true)
    }

    func stopEstateSync() {
        lastRefresh = Date().toMillis()
        refreshControl.endRefreshing()
        emptyListView.enableRefresh(enable: true)
        isRefreshing = false
    }
}

extension EstateListVC: SimpleActionableViewDelegate {
    func didTappedActionButton(view _: SimpleActionableView) {
        // FIre a sync
        log.info("Sync fired from 'refresh' button")

        startEstateSync()
    }

    func setupEmptyTableView() {
        let image: UIImage
        let title: String
        let description: String

        if isAssignedTo {
            image = UIImage(named: "empty-hunting")!
            title = "No active hunts found"
            description = "Please try to change the filters to find them"
        } else {
            image = UIImage(named: "empty-hunt-list")!
            title = "No hunt found"
            description = "You can try refreshing the list or changing the current filters"
        }

        let actionTitle = "Refresh"

        emptyListView = SimpleActionableView(image: image, title: title, description: description, actionTitle: actionTitle)
        emptyListView.setup(view: view, delegate: self)
    }
}

extension EstateListVC: EstateFilterMenuVCDelegate {
    func didChangeFilter(controller: EstateFilterMenuVC, filterModel: EstateFilterModel) {
        self.filterModel = filterModel

        reloadAndFetchResults()
//        estateListView.tableView.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }

    func didNotChangeFilter(controller: EstateFilterMenuVC) {
        controller.dismiss(animated: true, completion: nil)
    }
}
