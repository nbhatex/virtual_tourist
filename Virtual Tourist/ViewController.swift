//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 14/03/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
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
        
        mapView.region = MKCoordinateRegion(center: center, span: span)
        // TODO
        // Setting the delegate after the values are read 
        // Otherwise values can be overriden by the first call to mapView
        // Need to check if there is a better way
        // Zoomlevel is not right 
        
        mapView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTapOfMap:")
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func onTapOfMap(gestureRecoginizer:UIGestureRecognizer){
        let touchPoint = gestureRecoginizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
    }
    
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapCurrentRegion()
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapCurrentRegion()
    }
    
}

