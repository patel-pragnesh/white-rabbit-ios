//
//  CatsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import SideMenu

class AnimalsTableViewController: PFQueryTableViewController, Menu {

    var menuItems = [UIView]()
    
    override init(style: UITableViewStyle, className: String!) {
        NSLog("initializing animals table view controller: \(className)")
        
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func queryForTable() -> PFQuery {
        NSLog("queryForTable: " + self.parseClassName!)
        let query = PFQuery(className: self.parseClassName!)
        query.orderByAscending("name")
        query.includeKey("breed")
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.hidden = false
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

    }
    
    func showAddAminalView() {
        self.performSegueWithIdentifier("AnimalTableToAddAnimal", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        let menuImage = UIImage(named: "menu_white")
        let menuButton = UIButton(type: .Custom)
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.frame = CGRectMake(0, 0, 25, 15)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        let addImage = UIImage(named: "add_white")
        let addButton = UIButton(type: .Custom)
        addButton.setImage(addImage, forState: .Normal)
        addButton.frame = CGRectMake(0, 0, 25, 25)
        addButton.addTarget(self, action: "showAddAminalView", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalCell", forIndexPath: indexPath) as? AnimalsTableViewCell
        
        if cell == nil  {
            cell = AnimalsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalCell")
        }
        
        cell!.nameLabel.text = object?["name"] as? String
        
        let coverPhotoFile = object?["coverPhoto"] as? PFFile
        coverPhotoFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.coverPhoto.image = image
            }
        })
        
        let profilePhotoFile = object?["profilePhoto"] as? PFFile
        profilePhotoFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.profilePhoto.image = image
            }
        })
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "AnimalTableToAnimalDetail") {
            // Get the new view controller
            let detailScene = segue.destinationViewController as! AnimalDetailViewController
            
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                let object = objects?[row] as! PFObject
                
                detailScene.currentAnimalObject = object
            }
        }
    }
}
