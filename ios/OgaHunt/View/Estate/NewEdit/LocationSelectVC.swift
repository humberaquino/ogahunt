//
//  LocationSelectVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/8/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit
import UIKit

protocol LocationSelectVCDelegate: class {
    func didSelect(coordinate: CLLocationCoordinate2D?)
    func didCancelSelect()
}

class LocationSelectVC: UIViewController {
    weak var delegate: LocationSelectVCDelegate?

    // Location
    var locationManager = CLLocationManager()

    var mapView: MKMapView!
    var zoomLevel: Float = 14.0

    var selectedCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()

        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        view.addGestureRecognizer(uilgr)
    }

    @objc func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)

//        var touchPoint = gestureRecognizer.locationInView(mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//        var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

        selectedCoordinate = coordinate

        replaceMarkerWithSelectedCoordiante()
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self

        if selectedCoordinate == nil {
            // Just track when is new
            locationManager.startUpdatingLocation()
        } else {
            replaceMarkerWithSelectedCoordiante()
        }
    }

    func replaceMarkerWithSelectedCoordiante() {
        guard let selectedCoordinate = selectedCoordinate else { return }

        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        mapView.addAnnotation(annotation)

//            let marker = GMSMarker(position: selectedCoordinate)
//            marker.title = "Selected"
//            marker.snippet = "Info window text"
//            marker.map = mapView
    }

    func setupUI() {
        setupMap()
        setupTopBar()
    }

    func setupMap() {
//        var latitude = -33.86
//        var longitude = 151.20
//        if let selectedCoordinate = selectedCoordinate {
//            latitude = selectedCoordinate.latitude
//            longitude = selectedCoordinate.longitude
//        }

        mapView = MKMapView()
        mapView.showsUserLocation = true

//        mapView.register(EstateAnnotationView.self,
//                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//        mapView.delegate = self
        view.addSubview(mapView)

        mapView.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
            make.size.equalTo(self.view.snp.size)
        }

        if let initialLocation = selectedCoordinate {
            let location = CLLocation(latitude: initialLocation.latitude, longitude: initialLocation.longitude)
            centerMapOnLocation(location: location)
        }

        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
//        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

//        mapView.isMyLocationEnabled = true
//        mapView.delegate = self

//        view = mapView
    }

    func setupTopBar() {
        // Add close modal button
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        navigationItem.rightBarButtonItem = rightBarButton

        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
        navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func doneAction(_: Any) {
        log.info("Save location")
        delegate?.didSelect(coordinate: selectedCoordinate)
    }

    @objc func cancelAction(_: Any) {
        log.info("Cancel location")
        delegate?.didCancelSelect()
    }

    let regionRadius: CLLocationDistance = 500
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension LocationSelectVC: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")

        centerMapOnLocation(location: location)

//        selectedCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        replaceMarkerWithSelectedCoordiante()
        // Finally stop updating location otherwise it will come again and again in this delegate
//        self.locationManager.stopUpdatingLocation()
    }

    // Handle authorization for the location manager.
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            print("Location status is OK.")
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("---> Error: \(error)")
    }

//    func centerToLocation(location: CLLocation) {
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
//                                              longitude: location.coordinate.longitude,
//                                              zoom: zoomLevel)
//
//        if mapView.isHidden {
//            mapView.isHidden = false
//            mapView.camera = camera
//        } else {
//            mapView.animate(to: camera)
//        }
//    }
}

// extension LocationSelectVC: GMSMapViewDelegate {
//    func mapView(_: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        print("Tapepd at \(coordinate)")
//
//        selectedCoordinate = coordinate
//        replaceMarkerWithSelectedCoordiante()
//    }
//
//    func didTapMyLocationButton(for _: GMSMapView) -> Bool {
//        return true
//    }
//
//    func mapView(_: GMSMapView, didTapMyLocation _: CLLocationCoordinate2D) {
//        print("My location!")
//    }
//
//    func replaceMarkerWithSelectedCoordiante() {
//        guard let selectedCoordinate = selectedCoordinate else { return }
//        mapView.clear()
//        let marker = GMSMarker(position: selectedCoordinate)
//        marker.title = "Selected"
//        marker.snippet = "Info window text"
//        marker.map = mapView
//    }
// }
