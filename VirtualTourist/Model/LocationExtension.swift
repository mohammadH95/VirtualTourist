//
//  LocationExtension.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 26/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import Foundation
import MapKit

extension Location {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    func compare(to coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
    
    
    
}
