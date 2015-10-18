//
//  SheltersMapViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import BTNavigationDropdownMenu

class SheltersMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        NSLog("initializing shelters map view controller")

        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.hidden = false
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationController?.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        
        let items = ["Shelters", "Vets", "Pet Supplies", "Grooming"]
        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items)
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellBackgroundColor = UIColor.darkGrayColor()
        self.tabBarController?.navigationItem.titleView = menuView
        self.navigationItem.titleView = menuView
        
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

        self.populateShelters()
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
            performSegueWithIdentifier("MapToShelterDetail", sender: annotationView)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        let detailScene = segue.destinationViewController as! ShelterDetailViewController

        let annotationView = sender as! MKAnnotationView
        let annotation = annotationView.annotation as? Shelter
        
        detailScene.currentShelterObject = annotation?.parseObject
        
        // Pass the selected object to the destination view controller.
//        if let indexPath = self.tableView.indexPathForSelectedRow {
//            let row = Int(indexPath.row)
//            let object = objects?[row] as! PFObject
//            
//            NSLog("Viewing shelter detail for object: %@\n", object)
//            detailScene.currentShelterObject = object
//        }
    }
    
//
//    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//        NSLog("selected annotation")
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("calloutTapped:"))
//        // tapGesture.setValue(view, forKey: "shelter")
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    func calloutTapped(sender: UITapGestureRecognizer) {
//
////        let annotation = sender.valueForKey("shelter") as? MKAnnotationView
////        NSLog("callout tapped: " + ((annotation?.annotation?.title)!)!)
//        
//        let annotationView = sender.view as! MKPinAnnotationView
//        let annotation = annotationView.annotation as MKAnnotation!
//
//        NSLog("callout tapped : " + annotation.title!!)
//    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        NSLog("region changed")
//    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Errors: " + error.localizedDescription)
    }
    
    func populateShelters(){
        let query : PFQuery = self.queryForTable()

        query.findObjectsInBackgroundWithBlock { (NSArray objects, NSError error) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let shelter = Shelter(parseObject: object)
                        
                        self.addShelterToMap(shelter)
                    }
                }
            } else {
                print("There was an error")
            }
        }
        
    }
    
    func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Shelter")
        query.orderByAscending("name")
        return query
    }
    
    func addShelterToMap(shelter: Shelter) {
        self.mapView.addAnnotation(shelter)
    }

    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
