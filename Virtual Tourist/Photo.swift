//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 02/04/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary:[String:AnyObject], context:NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!,insertIntoManagedObjectContext:context)
        imageURL = dictionary["url_m"]! as? String
    }


}
