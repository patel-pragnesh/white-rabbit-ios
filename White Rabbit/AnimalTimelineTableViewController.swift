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
import GKImagePicker
import Social

class AnimalTimelineTableViewController: PFQueryTableViewController, GKImageCropControllerDelegate {

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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0 ) {
            NSLog("scrolled to the top")
            self.showTraits()
        } else {
            self.hideTraits()
        }
    }
    
    func hideTraits() {
        let pvc = self.parentViewController as! AnimalDetailViewController
//        UIView.transitionWithView(pvc.viewIfLoaded!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        pvc.addButton.hidden = true
    }
    
    func showTraits() {
        let pvc = self.parentViewController as! AnimalDetailViewController
//        UIView.transitionWithView(pvc.viewIfLoaded!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        pvc.addButton.hidden = false
    }
    
    func showActionSheet(sender: AnyObject, indexPath: NSIndexPath?) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)

        let shareAction = UIAlertAction(title: "Share", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Sharing entry")
            let image = self.imageAtCell(indexPath)!
            let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image], applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
        })

        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Deleting timeline entry")
            self.deleteEntry(indexPath)
        })
        
        let profilePhotoAction = UIAlertAction(title: "Set as Profile Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting profile photo")
            self.setProfilePhoto(self.imageAtCell(indexPath)!)
        })

        let coverPhotoAction = UIAlertAction(title: "Set as Cover Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting cover photo")
            self.setCoverPhoto(self.imageAtCell(indexPath)!)
        })

        
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(profilePhotoAction)
        optionMenu.addAction(coverPhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func imageAtCell(indexPath: NSIndexPath?) -> UIImage? {
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell
        let image = cell!.timelineImageView.image
        return image
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

    func setCoverPhoto(image : UIImage) {
        let cropController = GKImageCropViewController()
        NSLog("original image size: \(image.size)")
        cropController.sourceImage = image
        NSLog("source image size: \(cropController.sourceImage.size)")
        cropController.resizeableCropArea = false
        cropController.cropSize = CGSizeMake(320, 160)
        cropController.delegate = self
        self.presentViewController(cropController, animated: true, completion: nil)
//        self.navigationController!.pushViewController(cropController, animated: true)
    }
    
    func imageCropController(imageCropController: GKImageCropViewController!, didFinishWithCroppedImage croppedImage: UIImage!) {
        if let object = self.animalObject {
            NSLog("cropped image size: \(croppedImage.size)")
            let imageFile = PFFile(data: UIImageJPEGRepresentation(croppedImage, 1.0)!)
            object.setValue(imageFile, forKey: "coverPhoto")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                NSLog("finished saving cover photo")
            })
        }
        
        imageCropController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setProfilePhoto(image : UIImage) {
        if let object = self.animalObject {
            let imageFile = PFFile(data: UIImageJPEGRepresentation(image, 0.5)!)
            object.setValue(imageFile, forKey: "profilePhoto")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                NSLog("finished saving profile photo")
            })
        }
    }
    
    func incrementIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        var nextIndexPath: NSIndexPath?
        let nextRow = indexPath.row - 1
        let currentSection = indexPath.section
        
        nextIndexPath = NSIndexPath(forRow: nextRow, inSection: currentSection)
        
        return nextIndexPath
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("date")
        query.includeKey("shelter")
        if(self.animalObject != nil) {
            query.whereKey("animal", equalTo: animalObject!)
        }
        return query
    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.media.count
//    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalTimelineCell", forIndexPath: indexPath) as? AnimalTimelineTableViewCell
        if cell == nil  {
            cell = AnimalTimelineTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalTimelineCell")
        }

        cell!.timelineImageView.hidden = true
        if let imageFile = object?["image"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.timelineImageView.hidden = false
                    cell!.timelineImageView.image = image
                }
            })
        } else {
            cell!.timelineImageView.hidden = true
        }

        // Extract values from the PFObject to display in the table cell
        if let text = object?["text"] as? String {
            NSLog("setting cell text to: \(text)")

            
            switch object?["kind"] as! Int {
            case 2:
                cell!.largeIcon.image = UIImage(named: "timeline_medical")
                cell!.largeIcon.hidden = false
                break
            case 3:
                cell!.largeIcon.image = UIImage(named: "timeline_adopted")
                cell!.largeIcon.hidden = false
                break
            case 4:
                cell!.largeIcon.image = UIImage(named: "timeline_born")
                cell!.largeIcon.hidden = false
                break
            case 5:
                cell!.largeIcon.image = UIImage(named: "timeline_birthday")
                cell!.largeIcon.hidden = false
                break
            default:
                cell!.largeIcon.image = UIImage()
                cell!.largeIcon.hidden = true
                break
        }

            cell!.eventTextLabel.text = text
            cell!.eventTextLabel.hidden = false            
        } else {
            cell!.eventTextLabel.hidden = true
        }
        
        if let shelter = object?.objectForKey("shelter") as? PFObject {
            cell!.shelterButton.titleLabel?.textAlignment = .Center
            cell!.shelterButton.setTitle(shelter.valueForKey("name") as? String, forState: .Normal)
            cell!.shelterButton.hidden = false
        } else {
            cell!.shelterButton.setTitle("", forState: .Normal)
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
