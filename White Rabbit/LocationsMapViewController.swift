//
//  LocationsMapViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import BTNavigationDropdownMenu

class LocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var selectedType: String = "shelter"
    let items = ["Shelter", "Vet", "Supplies", "Grooming"]
    
    var locationsTableController: LocationsTableViewController?
    
    override func viewDidLoad() {
        NSLog("initializing shelters map view controller")

        super.viewDidLoad()
        
        self.setUpMenuBarController()
        
        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items, nav: self.navigationController!)

        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.selectedType = self.items[indexPath].lowercaseString
            NSLog("Did select : \(self.selectedType)")
            self.populateLocations()
        }
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellBackgroundColor = UIColor.darkGrayColor()
        self.navigationItem.titleView = menuView
        
//        self.setUpNavigationBarImage(UIImage(named: "locations_header")!, height: 220)
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        
        initializeMap()
    }
        
    func initializeMap() {
//        let initialLocation = CLLocation(latitude: 34.044467, longitude: -118.442708)
//        let regionRadius: CLLocationDistance = 1000
        self.mapView.showsUserLocation = true

        self.populateLocations()
//        self.centerMapOnLocation(initialLocation, regionRadius: regionRadius)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if(pinView == nil){
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            
            let calloutButton = UIButton(type: .InfoLight)
            pinView!.rightCalloutAccessoryView = calloutButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }

    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            NSLog("callout")
            performSegueWithIdentifier("MapToLocationDetail", sender: annotationView)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        if(segue.identifier == "MapToLocationDetail") {
            NSLog("performing maptolocation")
            let detailScene = segue.destinationViewController as! LocationDetailViewController

            let annotationView = sender as! MKAnnotationView
            let annotation = annotationView.annotation as? Location
            
            detailScene.currentLocationObject = annotation?.parseObject
        } else if(segue.identifier == "LocationTableEmbed") {
            let tableNav = segue.destinationViewController as! UINavigationController
            let tableScene = tableNav.topViewController as! LocationsTableViewController
//            let tableScene = segue.destinationViewController as! LocationsTableViewController
            tableScene.mapViewController = self
            tableScene.selectedType = self.selectedType
            tableScene.loadObjects()
            self.locationsTableController = tableScene
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Errors: " + error.localizedDescription)
    }
    
    func populateLocations(){
        let query : PFQuery = self.queryForTable()

        self.clearMap()
        
        query.findObjectsInBackgroundWithBlock { (NSArray objects, NSError error) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let location = Location(parseObject: object)
                        
                        self.addLocationToMap(location)
                    }
                }
            } else {
                print("There was an error")
            }
        }
        
        self.locationsTableController?.selectedType = self.selectedType
        self.locationsTableController?.loadObjects()
    }
    
    func clearMap() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Location")
        query.orderByAscending("name")
        query.whereKey("type", equalTo: self.selectedType)
        return query
    }
    
    func addLocationToMap(location: Location) {
        self.mapView.addAnnotation(location)
    }

    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}


class Location: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    var parseObject: PFObject?
    
    init(parseObject: PFObject) {
        self.title = parseObject["name"] as? String
        
        if let location = parseObject["geo"] as? PFGeoPoint {
            self.coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.parseObject = parseObject
        
        super.init()
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.title = name
        self.coordinate = coordinate
        
        super.init()
    }
}

