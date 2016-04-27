//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 15/03/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var id:String
    @NSManaged var photos:NSSet

}
