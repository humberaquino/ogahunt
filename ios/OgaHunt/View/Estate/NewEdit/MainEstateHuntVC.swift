//
//  MainEstateHuntVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
//import ImagePicker
import PKHUD
import UIKit
import CamMap

class MainEstateHuntVC: UIViewController {
    // Persistence
    var coreDataStack: CoreDataStack!
    var estateService: EstateService!

    // View
    var currentChildVC: UIViewController?

    var estateResponse: EstateResponse = EstateResponse.buildEmpty()!
    var estateImages: [UIImage] = []

    var currentHuntState = HuntState.mediaAndLocation

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }

    func setupPersistence(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        estateService = EstateService(managedObjectContext: coreDataStack.managedContext)
    }

    func updateView() {
        switch currentHuntState {
        case .mediaAndLocation:
            let imagePicker = buildImageAndLocationPickerController()
            setCurrentViewControllerAsChild(childViewController: imagePicker)
//        case .location:
//            let locationVC = buildLocationSelectVC()
//            setCurrentViewControllerAsChild(childViewController: UINavigationController(rootViewController: locationVC))
        case .details:
            let estateForm = buildEstateFormDetailsVC()
            setCurrentViewControllerAsChild(childViewController: UINavigationController(rootViewController: estateForm))
        case .done:
            handleDoneState()
        }
    }

    func goToNextStep() {
        currentHuntState = currentHuntState.nextState()
        updateView()
    }

    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    func handleDoneState() {
        print("Done")

        // Show HUD
        log.info("Sync success!")
        HUD.show(.label("Saving..."))

        // Save estate

        let estateSyncher = EstateSyncAction(context: coreDataStack.managedContext)

        estateSyncher.saveEstateRemotelly(estateResponse: estateResponse).then { estate in
//            HUD.flash(.success, delay: 0.5)
            HUD.show(.label("Uploading images..."))
            // TODO: Upload, save and associate images to this estate locally
            try self.estateService.append(images: self.estateImages, to: estate)
            // Use: self.estateImages

            estateSyncher.uploadAndSaveImages(estate: estate, saveEvent: false).then { results in
                print(results)
                HUD.flash(.success, delay: 0.5)
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                print(error)
                //            HUD.flash(.error, delay: 2.0)
                HUD.hide()
                let alert = Alert.simple(title: "Save failed", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }
        }.catch { error in
            print(error)
//            HUD.flash(.error, delay: 2.0)
            HUD.hide()
            let alert = Alert.simple(title: "Save failed", message: error.localizedDescription)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//// Media handling
//extension MainEstateHuntVC: ImagePickerDelegate {
//    func wrapperDidPress(_: ImagePickerController, images: [UIImage]) {
//        print("Wrapped did press: \(images.count)")
//    }
//
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        print("Done: \(images.count)")
//        if images.isEmpty {
//            let alert = Alert.simple(title: "Validation failed", message: "Please select at least one image")
//            imagePicker.present(alert, animated: true, completion: nil)
//            return
//        }
//
//        estateImages = images
//        goToNextStep()
//    }
//
//    func cancelButtonDidPress(_: ImagePickerController) {
//        print("Cancel")
//        handleCancel()
//    }
//}

// Location handling
extension MainEstateHuntVC: LocationSelectVCDelegate {
    func didSelect(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            log.debug("Location selected: \(coordinate)")
            estateResponse.updateWith(coordinate: coordinate)
        } else {
            log.debug("Location selected but is empty")
        }
        goToNextStep()
    }

    func didCancelSelect() {
        log.debug("Location select cancelled")
        handleCancel()
    }
}

extension MainEstateHuntVC: EstateFormDetailsVCDelegate {
    func didSaveForm(estateResponse _: EstateResponse) {
        log.debug("Form saved")
        goToNextStep()
    }

    func didCancelForm() {
        log.debug("Form cancelled")
        handleCancel()
    }
}


extension MainEstateHuntVC: CamMapDelegate {
    func camMapDidComplete(images: [UIImage], location: CLLocationCoordinate2D?) {
        if let coordinate = location {
            log.debug("Location selected: \(coordinate)")
            estateResponse.updateWith(coordinate: coordinate)
        } else {
            log.debug("Location selected but is empty")
        }
        estateImages = images
        goToNextStep()
    }

    func camMapDidCancel() {
        log.debug("Location select cancelled")
        handleCancel()
    }

    func camMapHadFailure(error: CamMapError) {
        log.error("Failure: \(error.localizedDescription)")
    }

    func camMapPermissionFailure(type: PermType, details: String) {
        log.error("Perms issue: \(details)")
    }
}

// Child container management
extension MainEstateHuntVC {
    func buildImageAndLocationPickerController() -> CamMapViewController {
        let camMapViewController = CamMapViewController()
        camMapViewController.delegate = self
//        imagePickerController.imageLimit = Limits.imageLimit
        return camMapViewController
    }

//    func buildImagePickerController() -> ImagePickerController {
//        let imagePickerController = ImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.imageLimit = Limits.imageLimit
//        return imagePickerController
//    }
//
//    func buildLocationSelectVC() -> LocationSelectVC {
//        let locationSelectVC = LocationSelectVC()
//        locationSelectVC.delegate = self
//        return locationSelectVC
//    }

    func buildEstateFormDetailsVC() -> EstateFormDetailsVC {
        let estateFormVC = EstateFormDetailsVC()
        estateFormVC.setupWith(estateResponse: estateResponse, stack: coreDataStack)
        estateFormVC.delegate = self
        return estateFormVC
    }

    private func setCurrentViewControllerAsChild(childViewController: UIViewController) {
        removeViewControllerAsChild(childViewController: currentChildVC)
        addViewControllerAsChild(childViewController: childViewController)
        currentChildVC = childViewController
    }

    private func addViewControllerAsChild(childViewController: UIViewController) {
        addChild(childViewController)
        view.addSubview(childViewController.view)

        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        childViewController.didMove(toParent: self)
    }

    private func removeViewControllerAsChild(childViewController: UIViewController?) {
        guard let childViewController = childViewController else {
            return
        }
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
}
