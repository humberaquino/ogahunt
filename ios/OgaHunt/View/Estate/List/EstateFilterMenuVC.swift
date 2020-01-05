//
//  EstateFilterMenuVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/7/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Eureka
import UIKit

protocol EstateFilterMenuVCDelegate: class {
    func didChangeFilter(controller: EstateFilterMenuVC, filterModel: EstateFilterModel)
    func didNotChangeFilter(controller: EstateFilterMenuVC)
}

class EstateFilterMenuVC: FormViewController {
//    var filterView = EstateFilterMenuView()
    var filterBySection: SelectableSection<ListCheckRow<EstateFilterListOnly>>!
    var sortBySection: SelectableSection<ListCheckRow<EstateFilterSortBy>>!
    var orderBySection: SelectableSection<ListCheckRow<SortOrder>>!

    var initialFilterModel: EstateFilterModel!

    var delegate: EstateFilterMenuVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.setupUI()
            self.markSelectedListOnly()
        }

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        markSelectedListOnly()
    }

    func setup(filterModel: EstateFilterModel, delegate: EstateFilterMenuVCDelegate) {
        initialFilterModel = filterModel
        self.delegate = delegate
    }

    func setupUI() {
        setupTabBar()
        setupForm()
    }

    func markSelectedListOnly() {
        let selectedListOnly = initialFilterModel.listOnly.rawValue
        if let row: ListCheckRow<EstateFilterListOnly> = filterBySection.rowBy(tag: selectedListOnly) {
            row.didSelect()
        }

        let selectedSortBy = initialFilterModel.sortBy.rawValue
        if let row: ListCheckRow<EstateFilterSortBy> = sortBySection.rowBy(tag: selectedSortBy) {
            row.didSelect()
        }
        let selectedOrderBy = initialFilterModel.sortOrder.rawValue
        if let row: ListCheckRow<SortOrder> = orderBySection.rowBy(tag: selectedOrderBy) {
            row.didSelect()
        }
    }

    func setupTabBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        title = "Filter hunts"
    }

    func setupForm() {
        form.removeAll()

        filterBySection = SelectableSection<ListCheckRow<EstateFilterListOnly>>("Filter by", selectionType: .singleSelection(enableDeselection: false))
        form +++ filterBySection
        for option in EstateFilterListOnly.allvalues {
            form.last! <<< ListCheckRow<EstateFilterListOnly> { listRow in
                listRow.tag = option.rawValue
                listRow.title = option.rawValue
                listRow.selectableValue = option
                listRow.value = nil
            }
        }

        sortBySection = SelectableSection<ListCheckRow<EstateFilterSortBy>>("Sort by", selectionType: .singleSelection(enableDeselection: false))
        form +++ sortBySection
        for option in EstateFilterSortBy.allvalues {
            form.last! <<< ListCheckRow<EstateFilterSortBy> { listRow in
                listRow.tag = option.rawValue
                listRow.title = option.rawValue
                listRow.selectableValue = option
                listRow.value = nil
            }
        }

        orderBySection = SelectableSection<ListCheckRow<SortOrder>>("Order by", selectionType: .singleSelection(enableDeselection: false))
        form +++ orderBySection
        for option in SortOrder.allvalues {
            form.last! <<< ListCheckRow<SortOrder> { listRow in
                listRow.tag = option.rawValue
                listRow.title = option.rawValue
                listRow.selectableValue = option
                listRow.value = nil
            }
        }
    }

    @objc
    func doneAction(_: Any) {
        // Check if it changed or not. Let the delegate know

        let filterModel = buildModelFromForm()

        if filterModel == initialFilterModel {
            print("Same")
            delegate?.didNotChangeFilter(controller: self)
        } else {
            print("Different")
            delegate?.didChangeFilter(controller: self, filterModel: filterModel)
        }
    }

    func buildModelFromForm() -> EstateFilterModel {
        var filterModel = EstateFilterModel()

        if let selectedFitler = filterBySection.selectedRow(),
            let selectedValue = selectedFitler.value {
            filterModel.listOnly = selectedValue
        }

        if let selectedFitler = sortBySection.selectedRow(),
            let selectedValue = selectedFitler.value {
            filterModel.sortBy = selectedValue
        }

        if let selectedFitler = orderBySection.selectedRow(),
            let selectedValue = selectedFitler.value {
            filterModel.sortOrder = selectedValue
        }

        return filterModel
    }
}
