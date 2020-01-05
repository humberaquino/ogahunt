//
//  EventMainVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import PKHUD
import Promises
import SnapKit
import UIKit

class EstateEventsVC: BaseManagedViewController {
    // Constants
    let eventCellIdentifier = "eventCellIdentifier"

    var isRefreshing = false
    var observersConfigured = false

    var lastRefresh: Int64 = 0
    let refreshThresholdMillis: Int64 = 5 * 1000 // 5 secs

    private let refreshControl = UIRefreshControl()

    // Persistence
    var coreDataStack: CoreDataStack!

    // View
    var eventListView: EstateEventsView!

    // Service
    var estateService: EstateService!
    var estateFilter: EstateFilter?

    var filterModel = EstateFilterModel()

    var emptyListView: SimpleActionableView!

    var fetchedResultsController: NSFetchedResultsController<EstateEvent>!

    func buildFetchedResultsController() -> NSFetchedResultsController<EstateEvent> {
        let fetchRequest: NSFetchRequest<EstateEvent> = EstateEvent.fetchRequest()

        // Filter by
        // estateId != nil || changeType == "estate_deleted"
        let withEstate = NSPredicate(format: "estate != nil")
        let deleted = NSPredicate(format: "changeType == %@", "estate_deleted")
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [withEstate, deleted])

        // Sort & Order by
        let key = "insertedAt.sectionIdentifier"
        let sort = NSSortDescriptor(key: key, ascending: false)

        fetchRequest.sortDescriptors = [sort]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: key,
            cacheName: nil
        )
//        fetchedResultsController.delegate = self
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

    func sortPredicateFromFilter() -> NSSortDescriptor {
        let key = #keyPath(EstateEvent.insertedAt)
        return NSSortDescriptor(key: key, ascending: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Solves refresh flickering
        // Ref: https://stackoverflow.com/a/55342111/223228
        extendedLayoutIncludesOpaqueBars = true

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.setupUI()
            self.reloadEstateModels()
            self.setupObservers()
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
        log.info("[Events view] Sync success notification received!")

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
        reloadAndFetchResults()
        reloadEstateModels()
    }

    func setup(stack: CoreDataStack) {
        title = "Activities"
        coreDataStack = stack
        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
    }

    func reloadEstateModels() {
        //        coreDataStack.managedContext.mergeChanges(fromContextDidSave: <#T##Notification#>)
        eventListView.reloadData()
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
extension EstateEventsVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return estateResults?.count ?? 0
        guard let sections = fetchedResultsController.sections else { return 0 }

        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
//        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
//        return objects.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else { return nil }

        let currentSection = sections[section]
        let sectionName = currentSection.name

        // Format and return
        let name = formatDateString(sectionName)
        return name
    }

    func formatDateString(_ str: String) -> String {
        guard let date = str.toDate("yyyy-MM-dd") else {
            return str // better to show a date than nothing
        }

        let now = Date()

        // If today them show "Today"

        if now.year == date.year {
            if now.month == date.month && now.day == date.day {
                return "Today"
            } else {
                return date.toFormat("MMM dd")
            }

        } else {
            return date.toFormat("MMM dd yyyy")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: eventCellIdentifier, for: indexPath) as! EstateEventsViewCell
        // swiftlint:enable force_cast

        configure(cell: cell, for: indexPath)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 80
    }

    func configure(cell: EstateEventsViewCell, for indexPath: IndexPath) {
        let estate = fetchedResultsController.object(at: indexPath)
        cell.userService = UserService(managedObjectContext: coreDataStack.managedContext)

        let userId = AuthService().userId()
        cell.populate(with: estate, currentUserId: userId)
    }
}

// Table view Delegate
extension EstateEventsVC: UITableViewDelegate {
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

        let sections = fetchedResultsController.sections

        var name = "no-name"

        if let sections = sections {
            let currentSection = sections[section]
            let sectionName = currentSection.name
            name = formatDateString(sectionName)
        }
        // Format and return

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        label.text = name
        label.textAlignment = NSTextAlignment.center
        label.textColor = AppAppearance.current?.sectionText
        view.backgroundColor = AppAppearance.current?.sectionBg
        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(15)
        }

        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let estateEvent = fetchedResultsController.object(at: indexPath)

        guard let estate = estateEvent.estate else { return }

        // Present a Estate list view
        let estateShowVC = EstateShowVC()
        estateShowVC.setupWith(estate: estate, stack: coreDataStack)
        navigationController?.pushViewController(estateShowVC, animated: true)
    }

    func unassign(estate: Estate) {
        HUD.show(.label("Unassigning..."))
        let estateSyncAction = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncAction.unassignEstate(estate: estate).then { _ in
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

// extension EventMainVC: UserListVCDelegate {
//    func didSelect(estate: Estate?, user: User) {
//        print("User selected: \(user)")
//        guard let estate = estate else {
//            // TODO: Notify about this
//            print("Opps! This is a bug. No estate provided")
//            return
//        }
//
//        HUD.show(.label("Assigning estate..."))
//        let estateSyncher = EstateSyncher(context: coreDataStack.managedContext)
//        estateSyncher.assignEstate(estate: estate, to: user).then { _ in
//            HUD.flash(.success, delay: 0.5)
//
//            self.navigationController?.popViewController(animated: true)
//            }.catch { error in
//                HUD.hide()
//                let msg = ErrorMessageHandler.extractErrorDescription(error)
//                let alert = Alert.simple(title: "Assignment failure", message: msg)
//                self.present(alert, animated: true, completion: nil)
//        }
//    }
// }

// extension EstateEventsVC: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
//        eventListView.tableView.beginUpdates()
//    }
//
//    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?,
//                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            eventListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .delete:
//            eventListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
//        case .update:
//            if let cell = eventListView.tableView.cellForRow(at: indexPath!) as? EstateEventsViewCell {
//                configure(cell: cell, for: indexPath!)
//            } else {
//                log.warning("Unwrapped cell not of type EstateViewCell at \(indexPath!)")
//            }
//        case .move:
//            eventListView.tableView.deleteRows(at: [indexPath!], with: .automatic)
//            eventListView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        }
//    }
//
//    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
//        eventListView.tableView.endUpdates()
//        //        reloadEmptyStateForTableView(estateListView.tableView)
//    }
// }

// Tab bar delegate
extension EstateEventsVC: UITabBarDelegate {
    func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
        print("Selected: \(item.tag)")
    }
}

// Empty estate list
extension EstateEventsVC {
    func setupUI() {
        setupBase()
        setupTopBar()
        setupEstateList()
        setupEmptyTableView()
    }

    func setupBase() {
        view.removeAllSubView()
        eventListView = EstateEventsView()
        eventListView.tableView.tableFooterView = UIView(frame: CGRect.zero)

        log.debug("--> Event view configured")
        view.addSubview(eventListView)

        eventListView.snp.makeConstraints { make in
            make.size.equalTo(self.view)
        }
    }

    func setupTopBar() {
        title = titleFromFilter()

        // Filter button

//        let filterButton = UIBarButtonItem(image: UIImage(named: "filter-hunts"),
//                                           style: UIBarButtonItemStyle.plain,
//                                           target: self,
//                                           action: #selector(openFilterMenu(_:)))
//
//        let mapButton = UIBarButtonItem(image: UIImage(named: "map-pin"),
//                                        style: UIBarButtonItemStyle.plain,
//                                        target: self,
//                                        action: #selector(openMapList(_:)))

//        navigationItem.rightBarButtonItems = [filterButton, mapButton]
    }

//
//    @objc func openFilterMenu(_: Any) {
//        print("Open filter menu")
//
//        let filterVC = EstateFilterMenuVC()
//        filterVC.setup(filterModel: filterModel, delegate: self)
//        present(UINavigationController(rootViewController: filterVC), animated: true, completion: nil)
//    }
//
//    @objc func openMapList(_: Any) {
//        guard let estates = fetchedResultsController.fetchedObjects else {
//            showNoLocationAlert()
//            return
//        }
//
//        if !hasAtLeastOneLocation(estates) {
//            showNoLocationAlert()
//            return
//        }
//
//        let mapListVC = EstateMapListVC()
//        mapListVC.setup(stack: coreDataStack, estates: estates)
//        navigationController?.pushViewController(mapListVC, animated: true)
//    }

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
        //        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        //        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing please wait", attributes: attributes)

        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing, please wait")

        refreshControl.addTarget(self, action: #selector(refreshEstateData(_:)), for: .valueChanged)

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    func setupEstateList() {
        eventListView.tableView.dataSource = self
        eventListView.tableView.delegate = self
        eventListView.tableView.register(EstateEventsViewCell.self, forCellReuseIdentifier: eventCellIdentifier)
        //        estateListView

        setupRefreshControlFor(tableView: eventListView.tableView)
    }

    @objc private func refreshEstateData(_: Any) {
        startEventsSync()
    }

    func titleFromFilter() -> String {
        guard let estateFilter = estateFilter else {
            return title ?? ""
        }

        return "\(estateFilter.value.capitalized) list"
    }

    func startEventsSync() {
        if isRefreshing {
            print("Skip. Currently running")
            return
        }

        isRefreshing = true

        // Start refresh: show like pull-to refresh and disable button
        refreshControl.beginRefreshing()
        emptyListView.enableRefresh(enable: false)

        // Fire estate sync only
        SyncNotifier.fireEventsSync(force: true)
    }

    func stopEstateSync() {
        lastRefresh = Date().toMillis()
        refreshControl.endRefreshing()
        emptyListView.enableRefresh(enable: true)
        isRefreshing = false
    }
}

extension EstateEventsVC: SimpleActionableViewDelegate {
    func didTappedActionButton(view _: SimpleActionableView) {
        //        reloadAndFetchResults()
        // FIre a sync
        log.info("Sync fired from 'refresh' button")

        startEventsSync()
    }

    func setupEmptyTableView() {
        let image = UIImage(named: "team-work")!
        let title = "No activites just yet"
        let description = "Try refreshing to get the latest activities from your team"
        let actionTitle = "Refresh"

        emptyListView = SimpleActionableView(image: image, title: title, description: description, actionTitle: actionTitle)
        emptyListView.setup(view: view, delegate: self)
    }
}

extension EstateEventsVC: EstateFilterMenuVCDelegate {
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
