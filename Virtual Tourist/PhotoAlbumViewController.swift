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


class PhotoAlbumViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    var pin:Pin!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var photosToBeDeleted = [NSIndexPath]()
    var photosToBeInserted = [NSIndexPath]()
    
    let MAX_PHOTO_IN_LANDSCAPE = CGFloat(6.0)
    let MAX_PHOTO_IN_PORTRAIT = CGFloat(3.0)
    
    override func viewDidLoad() {
        refreshController()
        photoCollection.dataSource = self
        photoCollection.delegate = self
        fetchedResultController.delegate = self

    }
    override func viewWillAppear(animated: Bool) {
        let space: CGFloat = 3.0
        let size = view.frame.size
        let dimension:CGFloat = size.width >= size.height ? getPhotoDimension(size.width,space: space,numPhotos: MAX_PHOTO_IN_LANDSCAPE) :  getPhotoDimension(size.width,space: space,numPhotos: MAX_PHOTO_IN_PORTRAIT)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension,dimension)
        if pin.photos.count < 1 {
            downloadPhotos()
            
        }
        let annotation = MKPinAnnotation(pin: pin)
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 5,longitudeDelta: 5))
        
        message.hidden = true
    }
    
    func getPhotoDimension(totalWidth:CGFloat,space:CGFloat,numPhotos:CGFloat) -> CGFloat {
    
        return (totalWidth - ((numPhotos - 1.0) * space))/numPhotos
    }
    
    @IBAction func createNewCollection(sender: AnyObject) {
        for photo in pin.photos {
            (photo as! Photo).clearImageStore()
            sharedContext.deleteObject(photo as! NSManagedObject)
        }
        saveContext()
        downloadPhotos()
        
    }
    
    func refreshController() {
        do {
            try fetchedResultController.performFetch()
            
        } catch {
            print("Error while getting the pins")
            abort()
        }
    }

    func downloadPhotos(){
        activityIndicator.startAnimating()
        flickrManager.search(pin,completionHandler:{photosFromResult in
            
            // Non repetitive error occured related to
            //_referenceData64 only defined for abstract class
            // Moved saveContext inside main thread to solve the issue.
            dispatch_async(dispatch_get_main_queue(), {
                for photoFromResult in photosFromResult {
                    let photo = Photo(dictionary: photoFromResult, context: self.sharedContext)
                    photo.pin = self.pin
                }
                self.saveContext()
                self.activityIndicator.stopAnimating()
            })
            
            },failureHandler: {errorMessage in
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    self.message.hidden = false
                    self.message.text = errorMessage
                    
                })
        })
    }
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.pin)
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }()
    
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    var flickrManager: FlickrManager {
        return FlickrManager.sharedInstance
    }
    
    // MARK: Collection view delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultController.objectAtIndexPath(indexPath) as! Photo
        print(photo.id)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        cell.backgroundView = UIImageView(image: UIImage(named: "placeHolder"))
        if photo.image == nil {
            if let imgURL = photo.imageURL {
            flickrManager.getImage(imgURL,completionHandler:{data in
                photo.image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.backgroundView = UIImageView(image:photo.image )
                })
                
                },failureHandler: {errorMessage in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.message.hidden = false
                        self.message.text = errorMessage

                    })
            })
            }
        } else {
            cell.backgroundView = UIImageView(image: photo.image)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        
        let photo = self.fetchedResultController.objectAtIndexPath(indexPath) as! Photo
        photo.clearImageStore()
        self.sharedContext.deleteObject(photo)
        self.saveContext()

       
        
    }
    

    
    // MARK: NSFetchedController Delegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        photosToBeDeleted = [NSIndexPath]()
        photosToBeInserted = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
            case .Insert : photosToBeInserted.append(newIndexPath!)
            case .Delete : photosToBeDeleted.append(indexPath!)
           
            default : print("do nothing")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        photoCollection.performBatchUpdates({
            if !self.photosToBeDeleted.isEmpty {
                self.photoCollection.deleteItemsAtIndexPaths(self.photosToBeDeleted)
            }
            if !self.photosToBeInserted.isEmpty {
                self.photoCollection.insertItemsAtIndexPaths(self.photosToBeInserted)
            }
        }, completion: nil)
    }
}
