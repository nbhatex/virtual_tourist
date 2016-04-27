//
//  MKPinAnnotation.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 03/04/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation
import MapKit

class MKPinAnnotation: MKPointAnnotation {
    
    var pin:Pin
    
    init(pin:Pin){

        self.pin = pin
        super.init()
        self.coordinate = pin.coordinate
    }

}