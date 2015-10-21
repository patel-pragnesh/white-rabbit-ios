//
//  SheltersTableViewController.swift
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

class SheltersTableViewController: PFQueryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpMenuBarController()
        
//        self.setUpLocationsMenu()

        
//        let nav = self.navigationController?.navigationBar
//        nav?.hidden = false
//        nav?.barStyle = UIBarStyle.BlackTranslucent
//        nav?.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        
        let items = ["Shelters", "Vets", "Pet Supplies", "Grooming"]
        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items, nav: self.navigationController!)
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellBackgroundColor = UIColor.darkGrayColor()
        self.navigationItem.titleView = menuView

        
//        let items = ["Shelters", "Vets", "Pet Supplies", "Grooming"]
//        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items)
//        menuView.cellBackgroundColor = UIColor.darkGrayColor()
//        menuView.cellTextLabelColor = UIColor.whiteColor()
//        menuView.tintColor = UIColor.whiteColor()
//        menuView.menuTitleColor = UIColor.whiteColor()
//        menuView.cellSelectionColor = UIColor.whiteColor()
//        menuView.tintColor = UIColor.whiteColor()
//        menuView.maskBackgroundColor = UIColor.whiteColor()
//        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
//        self.navigationItem.titleView = menuView
    }
    
    override init(style: UITableViewStyle, className: String!) {
        NSLog("initializing shelters table view controller: \(className)")

        super.init(style: style, className: className)
        
//        self.loadParseData()
    }
    
    required init(coder aDecoder:NSCoder) {
        NSLog("initializing required shelters table view controller")

        super.init(coder: aDecoder)!
        
        self.parseClassName = "Shelter"
        self.paginationEnabled = false
        self.pullToRefreshEnabled = false
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByAscending("name")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("ShelterCell", forIndexPath: indexPath) as? SheltersTableViewCell
        if cell == nil  {
            cell = SheltersTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ShelterCell")
        }
        
        cell!.frame.size.height = 200
        
        // Extract values from the PFObject to display in the table cell
        cell!.name.text = object?["name"] as? String
        
        let imageFile = object?["logo"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.logo.image = image
            }
        })
        
        return cell
    }
    
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        NSLog("selected cell #\(indexPath.row)!")
    //        self.performSegueWithIdentifier("bd_segue", sender: tableView)
    //    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        let detailScene = segue.destinationViewController as! ShelterDetailViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let row = Int(indexPath.row)
            let object = objects?[row] as! PFObject
            
            NSLog("Viewing shelter detail for object: %@\n", object)
            detailScene.currentShelterObject = object
        }
    }
}