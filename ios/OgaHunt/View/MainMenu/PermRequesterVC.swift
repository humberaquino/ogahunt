//
//  PermRequesterVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import UIKit

class PermRequesterVC: UIViewController {
    var coreDataStack: CoreDataStack!
    var permUtils: PermUtils!
    var originalController: UIViewController!

    var missingPerm: AppPerm?

    override func viewDidLoad() {
        super.viewDidLoad()

        on(Dev.INJECTION_BUNDLE_NOTIFICATION) {
            self.setupUI()
        }

        setupUI()
    }

    func setup(coreDataStack: CoreDataStack, permUtils: PermUtils, originalController: UIViewController) {
        self.coreDataStack = coreDataStack
        self.permUtils = permUtils
        self.originalController = originalController
    }

    func showMainHunt() {
        let mainEstateHunt = MainEstateHuntVC()
        mainEstateHunt.setupPersistence(coreDataStack: coreDataStack)
        navigationController?.pushViewController(mainEstateHunt, animated: true)
    }
}

extension PermRequesterVC {
    @objc func closeController(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func setupUI() {
        guard let missingPerm = self.missingPerm else {
            // TODO: Handle this case nicely
            return
        }

        // Replace left back button with a close
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeController(_:)))

        // Remove everything
        var permRequestView: PermRequesterView!
//        self.view = permRequestView
        switch missingPerm {
        case .camera:
            permRequestView = PermRequesterView(missingPerm: missingPerm, title: "Camera permission",
                                                subtitle: "OgaHunt needs to use your device's camera to hunt for estates effectively",
                                                imageName: "camera-perm",
                                                actionTitle: "Allow camera access")

        case .photos:
            permRequestView = PermRequesterView(missingPerm: missingPerm, title: "Photos permission",
                                                subtitle: "OgaHunt needs to use your device's photos library to store photos",
                                                imageName: "photos-perm",
                                                actionTitle: "Allow photos access")
        case .location:
            permRequestView = PermRequesterView(missingPerm: missingPerm, title: "Location permission",
                                                subtitle: "OgaHunt needs to use your device's location to hunt for estates effectively",
                                                imageName: "location-perm",
                                                actionTitle: "Allow location access")
        }

        permRequestView.setup(view: view, delegate: self)
//        self.view = permRequestView
    }
}

extension PermRequesterVC: PermRequesterViewDelegate {
    func didAcceptPermissionRequest(accepted: Bool, missingPerm: AppPerm) {
        switch missingPerm {
        case .camera:
            // Request camera perms
            permUtils.requestCameraPerms { accepted in
                if accepted {
                    // Go to next
                    print("Accepted camera")

                } else {
                    // Show a message and stay?
                    print("Denied camera")
                }

                self.goToNextPerm()
            }
        case .photos:
            // Request photos perms

            print("request photos")

            permUtils.requestPhotosPerms { accepted in
                if accepted {
                    // Go to next
                    print("Accepted photos")

                } else {
                    // Show a message and stay?
                    print("Denied photos")
                }

                self.goToNextPerm()
            }

        case .location:
            // Request location perms
            print("request location")

            permUtils.requestLocationPerms { accepted in
                if accepted {
                    // Go to next
                    print("Accepted location")

                } else {
                    // Show a message and stay?
                    print("Denied location")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.goToNextPerm()
                }
            }
        }
    }

    func goToNextPerm() {
        guard let currentMissingPerm = permUtils.currentMissingPerm() else {
            if permUtils.appHasSomeRestrictions() {
                print("All perms requested but some were denied!")
                // show alert for now
                let msg = "One or more permissions are missing. Please go to settings and enable them to be abel to hunt"
                let alert = Alert.simple(title: "Missing permissions", message: msg) {
                    self.dismiss(animated: true)
                }

                present(alert, animated: true)

            } else {
                print("All right! All perms granted!")
                let mainEstateHunt = MainEstateHuntVC()
                mainEstateHunt.setupPersistence(coreDataStack: coreDataStack)

                dismiss(animated: true) {
                    self.originalController.present(mainEstateHunt, animated: true)
                }
            }

//            navigationController?.pushViewController(mainEstateHunt, animated: true)
            return
        }

        // Request next one
        let permRequesterVC = PermRequesterVC()
        permRequesterVC.setup(coreDataStack: coreDataStack, permUtils: permUtils, originalController: originalController)
        permRequesterVC.missingPerm = currentMissingPerm
        navigationController?.pushViewController(permRequesterVC, animated: true)
    }
}
