//
//  ViewController.swift
//  Memorable Places
//
//  Created by Robert Byrne on 2015-07-14.
//  Copyright (c) 2015 Robert Byrne. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!

    @IBOutlet var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
            
            // Gets the long and lat of the cell clicked and then converts them to a double
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            
            // Setup the map based on the coordinated gotten above
            var coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            var latDelta: CLLocationDegrees = 0.01
            var longDelta: CLLocationDegrees = 0.01
            
            var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            var region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
            self.map.setRegion(region, animated: true)
            
            // Add annotation to the place
            var annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            
            annotation.title = places[activePlace]["name"]
            
            self.map.addAnnotation(annotation)
            
        }
        
        // REMEMBER! there must be a : after the action or we will get an error
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        uilpgr.minimumPressDuration = 2.0
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    // Get the users press location on the map and convert it to something we can use.
    func action(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            var touchPoint = gestureRecognizer.locationInView(self.map)
            
            var newCoordinate = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            var location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                
                if (error == nil) {
                    
                    if let p = CLPlacemark(placemark: placemarks?[0] as! CLPlacemark) {
                        
                        var subThoroughfare: String = ""
                        var thoroughfare: String = ""
                        
                        if p.subThoroughfare != nil {
                            
                            subThoroughfare = p.subThoroughfare
                            
                        }
                        
                        if p.thoroughfare != nil {
                            
                            thoroughfare = p.thoroughfare
                            
                        }
                        
                        title = "\(subThoroughfare) \(thoroughfare)"
                        
                    }
                        
                }
                if title == "" {
                    
                    title = "Added \(NSDate())"
                    
                }
                
                places.append(["name": title, "lat":"\(newCoordinate.latitude)", "lon":"\(newCoordinate.longitude)"])
                
                var annotation = MKPointAnnotation()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
            })
            
        }
        
    }
    
    
    // Location manager is setup to be a location and set the current map postition to the users current location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation: CLLocation = locations[0] as! CLLocation
        
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        
        var coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        var latDelta: CLLocationDegrees = 0.01
        var longDelta: CLLocationDegrees = 0.01
        
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.map.setRegion(region, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

