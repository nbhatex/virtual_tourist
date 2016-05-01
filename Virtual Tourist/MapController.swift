//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 14/03/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    var currentAnnotation:MKPinAnnotation!

    @IBOutlet weak var mapView: MKMapView!

    
    override func viewWillAppear(animated: Bool) {
        
        mapView.region = createRegionFromSavedData()
        
        // TODO
        // Setting the delegate after the values are read 
        // Otherwise values can be overriden by the first call to mapView
        // Need to check if there is a better way
        // Zoomlevel is not right 
        
        mapView.delegate = self
        
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapController.onTapOfMap(_:)))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func onTapOfMap(gestureRecoginizer:UIGestureRecognizer){
        
        let touchPoint = gestureRecoginizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

        
        if(gestureRecoginizer.state == UIGestureRecognizerState.Began ) {
            let pin = Pin(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, context: sharedContext)
            let annotation = MKPinAnnotation(pin: pin)
            mapView.addAnnotation(annotation)
            currentAnnotation = annotation
        }
        
        if(gestureRecoginizer.state == UIGestureRecognizerState.Changed ) {
            currentAnnotation.coordinate = CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        }
        
        if(gestureRecoginizer.state == UIGestureRecognizerState.Ended) {
            currentAnnotation.pin.latitude = touchMapCoordinate.latitude
            currentAnnotation.pin.longitude = touchMapCoordinate.longitude
            CoreDataStackManager.sharedInstance().saveContext()
            currentAnnotation = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error while getting the pins")
            abort()
        }
        
        var annotations = [MKAnnotation]()
        for fetchedObject in fetchedResultController.fetchedObjects! {
            let pin = fetchedObject as! Pin
            let annotation = MKPinAnnotation(pin:pin)
            annotations.append(annotation)
            
        }
        
        for annotation in self.mapView.annotations {
            self.mapView.removeAnnotation(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func saveMapCurrentRegion() {
        let center = mapView.region.center
        let latitude = center.latitude
        let longitude = center.longitude
        
        let span = mapView.region.span
        let latitudeDelta = span.latitudeDelta
        let longitudeDelta = span.longitudeDelta
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(latitude, forKey: "mapRegionCenterLatitude")
        userDefaults.setDouble(longitude, forKey: "mapRegionCenterLongitude")
        userDefaults.setDouble(latitudeDelta, forKey: "mapRegionCenterLatitudeDelta")
        userDefaults.setDouble(longitudeDelta, forKey: "mapRegionCenterLongitudeDelta")
    }
    
    func createRegionFromSavedData() -> MKCoordinateRegion {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var latitude = 0.0, longitude = 0.0, latitudeDelta = 100.0, longitudeDelta = 100.0
        if let value = userDefaults.valueForKey("mapRegionCenterLatitude") {
            latitude = value as! Double
        }
        
        if let value = userDefaults.valueForKey("mapRegionCenterLongitude") {
            longitude = value as! Double
        }
        
        if let value = userDefaults.valueForKey("mapRegionCenterLatitudeDelta") {
            latitudeDelta = value as! Double
        }
        
        if let value  = userDefaults.valueForKey("mapRegionCenterLongitudeDelta") {
            longitudeDelta = value as! Double
        }
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(mapViewRegionDidChangeFromUserInteraction()) {
            saveMapCurrentRegion()
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultController
        
    }()
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbum") as! PhotoAlbumViewController
        let pinAnnotation = view.annotation as? MKPinAnnotation
        controller.pin = pinAnnotation?.pin
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if (recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended) {
                    return true
                }
            }
        }
        return false
    }

}

