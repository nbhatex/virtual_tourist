//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 02/04/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imageURL: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    @NSManaged var id:String
 
}
