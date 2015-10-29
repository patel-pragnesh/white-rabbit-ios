//
//  AnimalTimelineTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/30/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class AnimalTimelineTableViewController: PFQueryTableViewController {

    var animalObject : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.tableView.rowHeight = UITableViewAutomaticDimension
        // self.tableView.estimatedRowHeight = 140.0
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureRecognizer.minimumPressDuration = 1.0
        // gestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(gestureRecognizer)
        
        self.tableView.estimatedRowHeight = 84.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.layoutIfNeeded()
        // self.tableView.sizeToFit()
        
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        
        if (indexPath == nil) {
            NSLog("long press on table view but not on a row");
        } else if (gestureRecognizer.state == .Began) {
            NSLog("long press on table view at row %d", indexPath!.row);
        } else {
            NSLog("gestureRecognizer.state = %d", gestureRecognizer.state.rawValue);
        }
        
        self.showActionSheet(self, indexPath: indexPath)
    }
    
    func showActionSheet(sender: AnyObject, indexPath: NSIndexPath?) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Deleting timeline entry")
            self.deleteEntry(indexPath)
        })
        
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func deleteEntry(indexPath: NSIndexPath?) {
        let object = self.objectAtIndexPath(indexPath)
        object?.deleteInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
            if(success) {
                NSLog("finished deleting")
                self.loadObjects()
            }
        })
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("date")
        if(self.animalObject != nil) {
            query.whereKey("animal", equalTo: animalObject!)
        }
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalTimelineCell", forIndexPath: indexPath) as? AnimalTimelineTableViewCell
        if cell == nil  {
            cell = AnimalTimelineTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalTimelineCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        if let text = object?["text"] as? String {
            cell!.eventTextLabel.text = text
        } else {
            cell!.eventTextLabel.hidden = true
        }
        
        if let imageFile = object?["image"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.timelineImageView.image = image
                    
//                    var frame = cell!.frame
//                    frame.size.height = (image?.size.height)!
//                    cell!.frame = frame
                }
            })
        } else {
            cell!.timelineImageView.hidden = true
        }
        
        let date = object?["date"] as? NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM"
        cell!.monthLabel.text = dateFormatter.stringFromDate(date!).uppercaseString

        dateFormatter.dateFormat = "dd"
        cell!.dayLabel.text = dateFormatter.stringFromDate(date!)

        dateFormatter.dateFormat = "yyyy"
        cell!.yearLabel.text = dateFormatter.stringFromDate(date!)

        return cell
    }
    
}
