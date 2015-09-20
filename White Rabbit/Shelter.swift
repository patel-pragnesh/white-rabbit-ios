//
//  Shelter.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import MapKit

class Shelter: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    var parseObject: PFObject?
    
    init(parseObject: PFObject) {
        self.title = parseObject["name"] as? String
        
        let location = parseObject["geo"] as! PFGeoPoint
        self.coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        self.parseObject = parseObject
        
        super.init()
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.title = name
        self.coordinate = coordinate
        
        super.init()
    }
    
//    var subtitle: String? {
//        return title
//    }
}
