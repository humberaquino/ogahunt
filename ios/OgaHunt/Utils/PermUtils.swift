//
//  PermUtils.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import AVFoundation
import CoreLocation
import Foundation
import Photos

enum AppPerm {
    case camera
    case photos
    case location
}

class PermUtils: NSObject {
    var hasPhotoPerms = false
    var reasonPhotosNoPerms: String?
    var photoPermsIsDenied: Bool = false

    var hasCameraPerms = false
    var reasonCameraNoPerms: String?
    var cameraPermsIsDenied: Bool = false

    var hasLocationPerms = false
    var reasonLocationNoPerms: String?
    var locationPermsIsDenied: Bool = false

    let locationManager = CLLocationManager()

    override init() {
        super.init()
        reloadPerms()
    }

    func reloadPerms() {
        _ = appHasPhotosPerms()
        _ = appHasCameraPerms()
        _ = appHasLocationPerms()
    }

    func currentMissingPerm() -> AppPerm? {
        if appHasAllPerms() {
            return nil
        }

        if !hasCameraPerms && !cameraPermsIsDenied {
            return .camera
        }

        if !hasPhotoPerms && !photoPermsIsDenied {
            return .photos
        }

        if !hasLocationPerms && !locationPermsIsDenied {
            return .location
        }

        return nil
    }

    func appHasAllPerms() -> Bool {
        reloadPerms()
        return hasPhotoPerms && hasCameraPerms && hasLocationPerms
    }

    func appHasSomeRestrictions() -> Bool {
        return photoPermsIsDenied || cameraPermsIsDenied || locationPermsIsDenied
    }

    func appHasCameraPerms() -> Bool {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .notDetermined:
            hasCameraPerms = false
            reasonCameraNoPerms = "Access not determined"
            cameraPermsIsDenied = false
        case .authorized:
            hasCameraPerms = true
            cameraPermsIsDenied = false
        case .restricted:
            hasCameraPerms = false
            cameraPermsIsDenied = true
            reasonCameraNoPerms = "Access restricted"
        case .denied:
            hasCameraPerms = false
            cameraPermsIsDenied = true
            reasonCameraNoPerms = "Access denied"
        }

        return hasCameraPerms
    }

    // Ref: https://stackoverflow.com/questions/26595343/determine-if-the-access-to-photo-library-is-set-or-not-phphotolibrary/32989022
    func appHasPhotosPerms() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()

        if status == PHAuthorizationStatus.authorized {
            hasPhotoPerms = true
            photoPermsIsDenied = false
        } else if status == PHAuthorizationStatus.denied {
            reasonPhotosNoPerms = "Access denied"
            hasPhotoPerms = false
            photoPermsIsDenied = true
        } else if status == PHAuthorizationStatus.notDetermined {
            reasonPhotosNoPerms = "Access not determined"
            hasPhotoPerms = false
            photoPermsIsDenied = false
        } else if status == PHAuthorizationStatus.restricted {
            // Restricted access - normally won't happen.
            reasonPhotosNoPerms = "Access restricted"
            hasPhotoPerms = false
            photoPermsIsDenied = true
        } else {
            reasonPhotosNoPerms = "Access unknown"
            hasPhotoPerms = false
            photoPermsIsDenied = false
        }

        return hasPhotoPerms
    }

    func appHasLocationPerms() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                reasonLocationNoPerms = "Enabled but status is not determined"
                hasLocationPerms = false
                locationPermsIsDenied = false
            case .restricted:
                reasonLocationNoPerms = "Enabled but status is restricted"
                hasLocationPerms = false
                locationPermsIsDenied = true
            case .denied:
                reasonLocationNoPerms = "Enabled but status is denied"
                hasLocationPerms = false
                locationPermsIsDenied = true
            case .authorizedAlways, .authorizedWhenInUse:
                hasLocationPerms = true
                locationPermsIsDenied = false
            }
        } else {
            reasonLocationNoPerms = "Disabled"
            hasLocationPerms = false
            locationPermsIsDenied = true
        }

        return hasLocationPerms
    }

    func requestCameraPerms(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            DispatchQueue.main.async {
                completion(granted)
            }
        })
    }

    func requestPhotosPerms(_ completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({ status in
            let authorized = status == .authorized
            DispatchQueue.main.async {
                completion(authorized)
            }
        })
    }

    var locationCompletion: ((Bool) -> Void)?

    func requestLocationPerms(_ completion: @escaping (Bool) -> Void) {
        locationCompletion = completion
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
}

extension PermUtils: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationCompletion?(true)
        } else {
            locationCompletion?(false)
        }
    }
}
