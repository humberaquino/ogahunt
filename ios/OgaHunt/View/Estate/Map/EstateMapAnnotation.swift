//
//  EstateMapAnnotation.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/9/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation
import MapKit

class EstateMapAnnotation: NSObject, MKAnnotation {
    // markerTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    var markerTintColor: UIColor {
        if let type = estate.type {
            switch type {
            case "land":
                return .green
            case "house":
                return .red
            case "duplex":
                return .yellow
            default:
                return .lightGray
            }
        } else {
            return .gray
        }
    }

    var estate: Estate
    var coordinate: CLLocationCoordinate2D {
        // Obs. Estate without coordinates are not even build
        return estate.location!.coordinates()
    }

    init(estate: Estate) {
        self.estate = estate
        super.init()
    }

    var title: String? {
        return estate.name
    }

    var subtitle: String? {
        return estate.address
    }
}

// class ArtworkMarkerView: MKMarkerAnnotationView {
//    override var annotation: MKAnnotation? {
//        willSet {
//            // 1
//            guard let artwork = newValue as? EstateMapAnnotation else { return }
//            canShowCallout = true
//            calloutOffset = CGPoint(x: -5, y: 5)
//            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            // 2
//            markerTintColor = artwork.markerTintColor
//            glyphText = String(artwork.discipline.first!)
//        }
//    }
// }

class EstateAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let estateMapAnnotation = newValue as? EstateMapAnnotation else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

//            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
//                                                    size: CGSize(width: 30, height: 30)))
//            mapsButton.setBackgroundImage(UIImage(named: "pin-simple"), for: UIControlState())
//            rightCalloutAccessoryView = mapsButton

            if let type = estateMapAnnotation.estate.type {
                image = UIImage(named: "pin-\(type)")
            } else {
                image = UIImage(named: "pin-simple")
            }
        }
    }
}
