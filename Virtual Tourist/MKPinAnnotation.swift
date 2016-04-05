//
//  MKPinAnnotation.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 03/04/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation
import MapKit

class MKPinAnnotation:NSObject, MKAnnotation {
    
    var pin:Pin
    
    init(pin:Pin){
        self.pin = pin
    }

    @objc var coordinate:CLLocationCoordinate2D{
        return pin.coordinate
    }
    
    func setCoordinate(newCoordinate:CLLocationCoordinate2D){
        //pin.setCoordinatenewCoordinate
    }
}