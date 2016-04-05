//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 25/03/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController:UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var pin:Pin!
    
    @IBOutlet weak var photoCollection: UICollectionView!
    
    override func viewDidLoad() {
        
        do {
            try fetchedResultController.performFetch()
            if fetchedResultController.fetchedObjects?.count < 1 {
                flickrManager.search(pin,completionHandler:{photosFromResult in
                    
                    for photoFromResult in photosFromResult {
                        let photo = Photo(dictionary: photoFromResult, context: self.sharedContext)
                        photo.pin = self.pin
                    }
                    self.saveContext()
                    },failureHandler: {errorMessage in
                        
                    })
            }
        } catch {
            print("Error while getting the pins")
            abort()
        }
        
        
        photoCollection.dataSource = self
       

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultController.objectAtIndexPath(indexPath) as! Photo
        print(photo.imageURL)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        cell.backgroundView = UIImageView(image: UIImage(named: "placeHolder"))
        flickrManager.getImage(photo.imageURL!,completionHandler:{data in
            
            cell.backgroundView = UIImageView(image: UIImage(data: data))
            },failureHandler: {errorMessage in
                
            })
        return cell
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.pin)
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    var flickrManager: FlickrManager {
        return FlickrManager.sharedInstance()
    }
}
