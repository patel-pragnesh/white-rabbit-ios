//
//  LocationsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import MapKit
import Parse
import ParseUI
import BTNavigationDropdownMenu

class LocationsTableViewController: PFQueryTableViewController {
    
    var selectedType: String = "shelter"
    let items = ["Shelter", "Vet", "Supplies", "Grooming"]
    var mapViewController : LocationsMapViewController?
    
    required init(coder aDecoder:NSCoder) {
        NSLog("initializing required shelters table view controller")
        
        super.init(coder: aDecoder)!
        
        self.parseClassName = "Location"
        self.paginationEnabled = false
        self.pullToRefreshEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setUpMenuBarController()
        
//        self.setUpLocationsMenu()
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
//        
//        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items, nav: self.navigationController!)
//        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
//            self.selectedType = self.items[indexPath].lowercaseString
//            NSLog("Did select : \(self.selectedType)")
//            self.loadObjects()
////            self.setCurrentView(items[indexPath])
//        }
//        menuView.cellTextLabelColor = UIColor.whiteColor()
//        menuView.cellBackgroundColor = UIColor.darkGrayColor()
//        self.navigationItem.titleView = menuView
        
//        self.setUpNavigationBarImage(UIImage(named: "locations_header")!, height: 220)
    }
    
    override init(style: UITableViewStyle, className: String!) {
        NSLog("initializing shelters table view controller: \(className)")

        super.init(style: style, className: className)
        
//        self.loadParseData()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey("type", equalTo: self.selectedType)
        query.orderByAscending("name")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationsTableViewCell
        if cell == nil  {
            cell = LocationsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LocationCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        cell!.name.text = object?["name"] as? String
        
        if let imageFile = object?["logo"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.logo.image = image
                }
            })
        } else {
            cell!.logo.image = nil
        }
            
        return cell
    }
    
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        NSLog("selected cell #\(indexPath.row)!")
    //        self.performSegueWithIdentifier("bd_segue", sender: tableView)
    //    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        
        if(segue.identifier == "LocationToLocationDetail") {
            let detailScene = segue.destinationViewController as! LocationDetailViewController
            
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                let object = objects?[row] as! PFObject
                
                NSLog("Viewing shelter detail for object: %@\n", object)
                detailScene.currentLocationObject = object
            }
        }
    }
}

class LocationsTableViewCell: PFTableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.height = 200
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

