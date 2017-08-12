//
//  BikeAnnotation.swift
//  BikeFinder
//
//  Created by Emre Dogan on 11/08/2017.
//  Copyright © 2017 Emre Dogan. All rights reserved.
//

import Foundation
import MapKit

let bike = ["city","race","family","mountain","tandem"]

class BikeAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    
    var bikeNumber: Int
    
    var bikeName: String
    
    var title: String?
    
    
    
    init(coordinate: CLLocationCoordinate2D, bikeNumber: Int) {
        self.coordinate = coordinate
        self.bikeNumber = bikeNumber
        self.bikeName = bike[bikeNumber - 1].capitalized
        self.title = self.bikeName
        print("BIKENAME")
    }
}
