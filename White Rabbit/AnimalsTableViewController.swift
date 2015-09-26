//
//  CatsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse

class AnimalsTableViewController: PFQueryTableViewController {

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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalCell", forIndexPath: indexPath) as? AnimalsTableViewCell
        
        if cell == nil  {
            cell = AnimalsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalCell")
        }
        
        cell!.nameLabel.text = object?["name"] as? String
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("preparing for segue")
        // Get the new view controller
        let detailScene = segue.destinationViewController as! AnimalDetailViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let row = Int(indexPath.row)
            let object = objects?[row] as! PFObject
            
            NSLog("Viewing detail for object: %@\n", object)
            detailScene.currentAnimalObject = object
        }
    }
}
