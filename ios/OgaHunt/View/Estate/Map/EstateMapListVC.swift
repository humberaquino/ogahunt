//
//  EstateMapListVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import MapKit
import SnapKit
import UIKit

class EstateMapListVC: UIViewController {
    var mapView: MKMapView!

    var estates: [Estate] = []
    var stack: CoreDataStack!

    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)

    func setup(stack: CoreDataStack, estates: [Estate]) {
        self.stack = stack
        self.estates = estates
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        mapView = MKMapView()
        mapView.showsUserLocation = true

        mapView.register(EstateAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        view.addSubview(mapView)

        mapView.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
            make.size.equalTo(self.view.snp.size)
        }

        var coordinates: [CLLocationCoordinate2D] = []

        estates.forEach { estate in
            if let location = estate.location {
//                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let artwork = EstateMapAnnotation(estate: estate)
                mapView.addAnnotation(artwork)

//                let loc = CLLocation(latitude: latitude, longitude: longitude)
//                centerMapOnLocation(location: loc)
                let coordinate = location.coordinates()
                coordinates.append(coordinate)
            }
        }

        let region = MKCoordinateRegion(coordinates: coordinates)
//        let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        centerMapOnLocation(region: region)
    }

    func centerMapOnLocation(region: MKCoordinateRegion) {
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
//                                                                  regionRadius, regionRadius)

//        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta)

//        let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
        mapView.setRegion(region, animated: true)
    }

//    func centerMapOnLocation(location: CLLocation) {
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
//                                                                  regionRadius, regionRadius)
//        mapView.setRegion(coordinateRegion, animated: true)
//    }
}

extension EstateMapListVC: MKMapViewDelegate {
    func mapView(_: MKMapView, didSelect _: MKAnnotationView) {
//        print("--> \(view.annotation)")
    }

    func mapView(_: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped _: UIControl) {
        guard let estateAnnotation = view.annotation as? EstateMapAnnotation else {
            return
        }

        // Open the estate
        let estate = estateAnnotation.estate
        let estateShowVC = EstateShowVC()
        estateShowVC.setupWith(estate: estate, stack: stack)
        navigationController?.pushViewController(estateShowVC, animated: true)
    }
}

extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        var minLatitude: CLLocationDegrees = 90.0
        var maxLatitude: CLLocationDegrees = -90.0
        var minLongitude: CLLocationDegrees = 180.0
        var maxLongitude: CLLocationDegrees = -180.0

        for coordinate in coordinates {
            let lat = Double(coordinate.latitude)
            let long = Double(coordinate.longitude)
            if lat < minLatitude {
                minLatitude = lat
            }
            if long < minLongitude {
                minLongitude = long
            }
            if lat > maxLatitude {
                maxLatitude = lat
            }
            if long > maxLongitude {
                maxLongitude = long
            }
        }

        let span = MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
        let center = CLLocationCoordinate2DMake((maxLatitude - span.latitudeDelta / 2), (maxLongitude - span.longitudeDelta / 2))
        self.init(center: center, span: span)
    }
}
