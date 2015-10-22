//
//  CatsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import BTNavigationDropdownMenu

class AnimalsTableViewController: PFQueryTableViewController {

    var owner : PFUser?
    var featured : Bool = false
    
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
        if self.owner != nil {
            NSLog("query for: \(owner)")
            query.whereKey("owner", equalTo: owner!)
        }
        if self.featured {
            query.whereKey("featured", equalTo: true)
        }
        query.orderByAscending("name")
        query.includeKey("breed")
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let items = ["Mine", "Featured"]
        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items, nav: self.navigationController!)
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            self.setCurrentView(items[indexPath])
        }
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellBackgroundColor = UIColor.darkGrayColor()
        self.navigationItem.titleView = menuView
        
        self.setCurrentUser()
        
        self.setUpMenuBarController()
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("add_white", action: "showAddAminalView", height: 25)        
    }
    
    func setCurrentUser() {
        let menuViewController = self.slideMenuController()?.leftViewController as! HomeViewController
        let user = menuViewController.currentUser as PFUser?
        NSLog("found user \(user)")
        if user != nil {
            self.owner = user!
        }
    }
    
    func setCurrentView(viewName: String) {
        switch viewName {
            case "Featured":
                self.featured = true
                self.owner = nil
                break
            case "Mine":
                self.featured = false
                self.setCurrentUser()
                break
            default:
                break
        }
        self.loadObjects()
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
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalCell", forIndexPath: indexPath) as? AnimalsTableViewCell
        
        if cell == nil  {
            cell = AnimalsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalCell")
        }
        
        cell!.nameLabel.text = object?["name"] as? String
        
        cell!.coverPhoto.image = UIImage(named: "blank_cover")
        let coverPhotoFile = object?["coverPhoto"] as? PFFile
        coverPhotoFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.coverPhoto.image = image
            }
        })
        
        cell!.profilePhoto.image = UIImage(named: "avatar_blank")
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
