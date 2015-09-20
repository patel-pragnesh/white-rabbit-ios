//
//  SheltersMapViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import MapKit

class SheltersMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var tableView: SheltersTableViewController!

    override func viewDidLoad() {
        NSLog("initializing shelters view controller")

        super.viewDidLoad()
        
//        let tableView = SheltersTableViewController(style: UITableViewStyle.Grouped, className: "Shelter")
        initializeMap()
    }
    
    func initializeMap() {
        let initialLocation = CLLocation(latitude: 34.044467, longitude: -118.442708)
        let regionRadius: CLLocationDistance = 1000

        // self.populateShelters()
        self.centerMapOnLocation(initialLocation, regionRadius: regionRadius)
    }
    
    func populateShelters() {
        let shelter = Shelter(
            name: "NKLA",
            coordinate: CLLocationCoordinate2D(latitude: 34.044467, longitude: -118.442708)
        )
        
        self.mapView.addAnnotation(shelter)
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
