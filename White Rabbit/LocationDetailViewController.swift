//
//  LocationDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsButton: UIButton!
    
    var currentLocationObject: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
//        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
//        self.navigationController?.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        
        if let object = currentLocationObject {
            NSLog("Viewing detail for Location: %@\n", object)
            
            nameLabel.text = object["name"] as? String
//            self.setUpNavigationBar(nameLabel.text!)
            address1Label.text = object["address"] as? String
            cityStateZipLabel.text = (object["city"] as! String) + ", " + (object["state"] as! String) + " " + (object["zip"] != nil ? (object["zip"] as! String) : "")
            
            phoneNumberButton.setTitle(object["phone"] as? String, forState: .Normal)
            websiteButton.setTitle(object["website"] as? String, forState: .Normal)

            
            let imageFile = object["logo"] as? PFFile
            imageFile?.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.logoImage.image = image
                }
            })
            
            if object["geo"] != nil {
                self.initializeMap()
            }
        }
    }
    
    @IBAction func openWebsite(sender: UIButton) {
        openUrl(sender.titleForState(.Normal))
    }
        
    @IBAction func callPhoneNumber(sender: UIButton) {
        let number = sender.titleForState(.Normal) as String!
        let strippedNumber = number.stringByReplacingOccurrencesOfString("\\D", withString: "", options: .RegularExpressionSearch, range: number.startIndex..<number.endIndex)
        openUrl("tel://" + strippedNumber)
    }
    
    @IBAction func openDirections(sender: UIButton) {
        openMapsAppWithDirections()
    }
        
    func openMapsAppWithDirections() {
        let coordinates = self.getCoordinates()
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = currentLocationObject?.valueForKey("name") as? String
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    func getCoordinates() -> CLLocationCoordinate2D {
        let location = currentLocationObject?.valueForKey("geo") as! PFGeoPoint
        
        let latitute:CLLocationDegrees =  location.latitude
        let longitute:CLLocationDegrees =  location.longitude
        
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        
        return coordinates
    }
    
    func initializeMap() {
        let coordinates = self.getCoordinates()
        let regionRadius: CLLocationDistance = 1000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 2.0)
        
        let location = Location(
            name: currentLocationObject?.valueForKey("name") as! String,
            coordinate: coordinates
        )

        mapView.addAnnotation(location)
        // mapView.selectAnnotation(location, animated: true)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.hidden = false
        directionsButton.hidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ShelterToAnimalsTable") {
            let tableViewController = segue.destinationViewController as! AnimalsTableViewController
            tableViewController.shelter = self.currentLocationObject
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
