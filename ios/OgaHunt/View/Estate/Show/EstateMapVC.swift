//
//  EstateMapVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import MapKit
import SnapKit
import UIKit

class EstateMapVC: UIViewController {
    var estate: Estate!

    var mapView: MKMapView!
    var noContactLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.reloadUI()
        }

        reloadUI()
    }

    func configWith(estate: Estate) {
        self.estate = estate
    }

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func reloadUI() {
        view.removeAllSubView()

        mapView = MKMapView()

        if let coordinate = estate.location?.coordinates() {
            let artwork = EstateMapAnnotation(estate: estate)
            mapView.addAnnotation(artwork)

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            centerMapOnLocation(location: location)

//            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
//            locationMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//            let marker = GMSMarker(position: coordinate)
//            marker.title = "Selected"
//            marker.snippet = "Info window text"
//            marker.map = locationMapView

            view.addSubview(mapView)

            mapView.snp.makeConstraints { make in
                make.top.equalTo(self.view.snp.top)
                make.bottom.equalTo(self.view.snp.bottom)
                make.left.equalTo(0)
                make.right.equalTo(0)
            }
        } else {
            noContactLabel = UILabel()
            noContactLabel.text = "No map selected 🗺"

            noContactLabel.textColor = UIColor.darkGray
            noContactLabel.textAlignment = .center
            noContactLabel.font = UIFont.systemFont(ofSize: 16)

            view.addSubview(noContactLabel)

            noContactLabel.snp.makeConstraints { make in
                make.centerX.equalTo(view.snp.centerX)
                make.centerY.equalTo(view.snp.centerY)
                make.height.equalTo(20)
                make.width.equalTo(200)
            }
        }
    }
}
