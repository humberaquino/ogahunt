//
//  EstateShowVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import CoreLocation
import ImageSlideshow
import Kingfisher
import PKHUD
import SnapKit
import SwiftPhotoGallery
import UIKit

class EstateShowVC: UIViewController {
    var images: [UIImage] = []

    let slideshow = UIImageView()

    var estateInfoTabVC: EstateShowTabDetailsVC!

    private var estate: Estate!
    private var coreDataStack: CoreDataStack!
    private var estateService: EstateService!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindow {
                if window.safeAreaInsets.bottom > 0 {
                    self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
                    self.navigationController?.navigationBar.prefersLargeTitles = true
                }
            }
        }

        // Print how much data uses
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewWithCurrentState()
    }

    func setupWith(estate: Estate, stack: CoreDataStack) {
        self.estate = estate
        coreDataStack = stack
        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
    }

    func updateViewWithCurrentState() {
        reloadMainImage()
        estateInfoTabVC.reloadUI()
    }

    @objc func editAction(_: Any) {
        let editAlert = UIAlertController(title: "Edit", message: nil, preferredStyle: UIAlertController.Style.actionSheet)

        editAlert.addAction(UIAlertAction(title: "Photos", style: UIAlertAction.Style.default, handler: { _ in
            let photosGalleryVC = self.buildPhotoGalleryVC()
            self.navigationController?.pushViewController(photosGalleryVC, animated: true)
        }))

        editAlert.addAction(UIAlertAction(title: "Location", style: UIAlertAction.Style.default, handler: { _ in
            let locationVC = self.buildLocationSelectVC()
            locationVC.selectedCoordinate = self.estate.location?.coordinates()
            self.navigationController?.pushViewController(locationVC, animated: true)
        }))

        editAlert.addAction(UIAlertAction(title: "Details", style: UIAlertAction.Style.default, handler: { _ in
            let detailsForm = self.buildEstateFormDetailsVC()
            self.navigationController?.pushViewController(detailsForm, animated: true)
        }))

        editAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in

        }))

        present(editAlert, animated: true, completion: nil)
    }
}

// Location handling
extension EstateShowVC: LocationSelectVCDelegate {
    func didSelect(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            log.debug("Location selected: \(coordinate)")

            if let locationResponse = checkAndBuildLocationUpdate(selectedCoordinate: coordinate) {
                HUD.show(.label("Updating location..."))

                let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
                estateSyncher.updateLocationRemotelly(estate: estate, locationResponse: locationResponse).then { result in
                    HUD.flash(.success, delay: 0.5)
                    print(result)

                    self.navigationController?.popViewController(animated: true)
                }.catch { error in
                    HUD.hide()
                    let msg = ErrorMessageHandler.extractErrorDescription(error)
                    let alert = Alert.simple(title: "Update failure", message: msg)
                    self.present(alert, animated: true, completion: nil)
                }

            } else {
                log.debug("Location didnt change")
                navigationController?.popViewController(animated: true)
            }
        } else {
            log.debug("Location selected but is empty")
        }
    }

    func didCancelSelect() {
        log.debug("Location select cancelled")
        navigationController?.popViewController(animated: true)
    }
}

// Details
extension EstateShowVC: EstateFormDetailsVCDelegate {
    func didSaveForm(estateResponse: EstateResponse) {
        log.debug("Form saved")

        HUD.show(.label("Updating estate..."))
        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)
        estateSyncher.updateEstateRemotelly(estateResponse: estateResponse).then { _ in
            HUD.flash(.success, delay: 0.5)
            self.updateTopBarTitle()
            self.navigationController?.popViewController(animated: true)
        }.catch { error in
            HUD.hide()

            let msg = ErrorMessageHandler.extractErrorDescription(error)
            let alert = Alert.simple(title: "Update failure", message: msg)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func didCancelForm() {
        log.debug("Form cancelled")
        navigationController?.popViewController(animated: true)
    }

    private func checkAndBuildLocationUpdate(selectedCoordinate: CLLocationCoordinate2D?) -> LocationResponse? {
        guard let selectedCoordinate = selectedCoordinate else {
            return nil
        }

        if let estateLocation = estate.location {
            // There's a location
            let currentCoordinate = CLLocationCoordinate2D(latitude: estateLocation.latitude, longitude: estateLocation.longitude)
            if currentCoordinate == selectedCoordinate {
                return nil
            }
        }

        // No location or different. Update
        let locationResponse = LocationResponse.buildEmpty()
        locationResponse.latitude = selectedCoordinate.latitude
        locationResponse.longitude = selectedCoordinate.longitude

        return locationResponse
    }
}

extension EstateShowVC {
    func buildPhotoGalleryVC() -> PhotoGalleryVC {
        let layout = UICollectionViewFlowLayout()
        let photoGalleryVC = PhotoGalleryVC(collectionViewLayout: layout)

        photoGalleryVC.setupWith(estate: estate, managedObjectContext: coreDataStack.managedContext)
        return photoGalleryVC
    }

    func buildLocationSelectVC() -> LocationSelectVC {
        let locationSelectVC = LocationSelectVC()
        locationSelectVC.delegate = self
        return locationSelectVC
    }

    func buildEstateFormDetailsVC() -> EstateFormDetailsVC {
        let estateFormVC = EstateFormDetailsVC()

        let estateResponse = estate.toEstateResponse()
        estateFormVC.setupWith(estateResponse: estateResponse, stack: coreDataStack)

        estateFormVC.delegate = self
        return estateFormVC
    }
}

extension EstateShowVC {
    private func setupUI() {
        setupTopBar()
        setupBase()
        setupChildSegments()
    }

    private func updateTopBarTitle() {
        title = estate.name ?? "Estate"
    }

    private func setupTopBar() {
        updateTopBarTitle()

        // Add close modal button
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    private func setupBase() {
        view.addSubview(slideshow)

        var slideshowHeight = 300
        if DeviceLayout.isSmallDevice() {
            slideshowHeight = 150
        }

        slideshow.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.height.equalTo(slideshowHeight)
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))

        slideshow.contentMode = .scaleAspectFill
        slideshow.clipsToBounds = true
        slideshow.isUserInteractionEnabled = true
        slideshow.addGestureRecognizer(tapGestureRecognizer)

        reloadMainImage()
    }

    @objc func imageTapped(_: AnyObject) {
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        navigationController?.navigationBar.isHidden = true
        let appTabBarController = tabBarController as? AppTabBarController
        appTabBarController?.hide()
        navigationController?.pushViewController(gallery, animated: true)
    }

    private func reloadMainImage() {

        images = estate.allImages()

        if let image = images.first {
            slideshow.image = image
        }

    }

    private func setupChildSegments() {
        estateInfoTabVC = EstateShowTabDetailsVC()

        estateInfoTabVC.setupWith(estate: estate)

        addChild(estateInfoTabVC)
        view.addSubview(estateInfoTabVC.view)

        estateInfoTabVC.view.snp.makeConstraints { make in
            make.top.equalTo(slideshow.snp.bottom)

            make.width.equalTo(self.view)
            make.bottom.equalTo(0)
        }

        estateInfoTabVC.didMove(toParent: self)
    }
}

extension EstateShowVC: SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource {
    func numberOfImagesInGallery(gallery _: SwiftPhotoGallery) -> Int {
        return images.count
    }

    func imageInGallery(gallery _: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return images[forIndex]
    }

    func galleryDidTapToClose(gallery _: SwiftPhotoGallery) {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
        let appTabBarController = tabBarController as? AppTabBarController
        appTabBarController?.unhide()
    }
}
