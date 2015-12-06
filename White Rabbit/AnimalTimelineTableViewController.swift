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
import CLImageEditor
import Social

class AnimalTimelineTableViewCell: PFTableViewCell {
    
    @IBOutlet weak var eventTextLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var timelineImageView: UIImageView!
    @IBOutlet weak var largeIcon: UIImageView!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var documentsButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartFilledButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!

    @IBOutlet weak var lovesCountLabel: UILabel!
    
    var indexPath: NSIndexPath?
    var parentTable: AnimalTimelineTableViewController?
    var type: String?
    
    var lovesCount : Int32 = 0
    var isLiked : Bool = false
    
    var entryObject : PFObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, type: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.hideAllButtons()

        self.type = type
        if self.type == "image" {
            self.showAllButtons()
        }
    }

    func showAllButtons() {
        self.heartButton.hidden = false
        self.commentButton.hidden = false
        self.shareButton.hidden = false
        self.flagButton.hidden = false
        self.moreButton.hidden = false
    }
    
    func hideAllButtons() {
        self.heartButton.hidden = true
        self.heartFilledButton.hidden = true
        self.commentButton.hidden = true
        self.shareButton.hidden = true
        self.flagButton.hidden = true
        self.moreButton.hidden = true
        self.lovesCountLabel.hidden = true
    }
    
    func setLikeCount(count: Int32) {
        self.lovesCount = count
        var text: String = "\(count) loves"
        if(count == 1) {
            text = String(text.characters.dropLast())
        }
        self.lovesCountLabel.hidden = false
        self.lovesCountLabel.text = text
    }
    
    func incrementLikeCount() {
        self.isLiked = true
        self.setLikeCount(self.lovesCount + 1)
    }

    func decrementLikeCount() {
        self.isLiked = false
        self.setLikeCount(self.lovesCount - 1)
    }

    
    func setHeartsDisabled() {
        self.heartButton.enabled = false
        self.heartFilledButton.enabled = false
    }

    func setHeartsEnabled() {
        self.heartButton.enabled = true
        self.heartFilledButton.enabled = true
    }
    
    func setEntryLiked() {
        self.isLiked = true
        self.heartButton.hidden = true
        self.heartFilledButton.hidden = false
    }

    func setEntryUnliked() {
        self.isLiked = false
        self.heartButton.hidden = false
        self.heartFilledButton.hidden = true
    }
    
    @IBAction func documentsButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func heartButtonPressed(sender: AnyObject) {
        parentTable?.likeEntryWithBlock(self.indexPath!, completionBlock: { (result, error) -> Void in
            self.heartButton.hidden = true
            self.heartFilledButton.hidden = false
        })
    }
    
    @IBAction func heartFilledButtonPressed(sender: AnyObject) {
        parentTable?.unlikeEntryWithBlock(self.indexPath!, completionBlock: { (result, error) -> Void in
            self.heartButton.hidden = false
            self.heartFilledButton.hidden = true
        })
    }
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        parentTable!.selectedIndexPath = self.indexPath!
        parentTable!.performSegueWithIdentifier("TimelineToEntryDetail", sender: self)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        parentTable!.showShareActionSheet(sender, indexPath: self.indexPath!)
    }
    
    @IBAction func flagButtonPressed(sender: AnyObject) {
        if self.flagButton.enabled {
            parentTable!.showFlagActionSheet(sender, indexPath: self.indexPath!)
        }
    }
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        if self.moreButton.enabled {
            parentTable!.showMoreActionSheet(sender, indexPath: self.indexPath!)
        }
    }
}

class AnimalTimelineTableViewController: PFQueryTableViewController, CLImageEditorDelegate {

    var animalObject : PFObject?
    var animalDetailController : AnimalDetailViewController?
    
    var isEditingProfile : Bool = false
    var isEditingCover : Bool = false
    
    var selectedIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylePFLoadingView()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureRecognizer.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(gestureRecognizer)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handlePress:")
//        self.tableView.addGestureRecognizer(tapRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.tableView.addGestureRecognizer(doubleTapRecognizer)

    }
    
    func likeEntryWithBlock(indexPath: NSIndexPath?, completionBlock: (result: Bool, error: NSError?) -> Void) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell {
            cell.setHeartsDisabled()
            let entry: PFObject? = self.objectAtCell(indexPath)
            let relation: PFRelation = entry!.relationForKey("likes")
            relation.addObject(PFUser.currentUser()!)
            entry?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                completionBlock(result: success, error: error)
                cell.incrementLikeCount()
                cell.setHeartsEnabled()
            })
        }
    }
    
    func unlikeEntryWithBlock(indexPath: NSIndexPath?, completionBlock: (result: Bool, error: NSError?) -> Void) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell {
            cell.setHeartsDisabled()
            let entry: PFObject? = self.objectAtCell(indexPath)
            let relation: PFRelation = entry!.relationForKey("likes")
            relation.removeObject(PFUser.currentUser()!)
            entry?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                completionBlock(result: success, error: error)
                cell.decrementLikeCount()
                cell.setHeartsEnabled()
            })
        }
    }
    
    func likeCountWithBlock(indexPath: NSIndexPath?, entry: PFObject, completionBlock: ((count: Int32, error: NSError?) -> Void)?) {
        let relation: PFRelation = entry.relationForKey("likes")
        relation.query().countObjectsInBackgroundWithBlock(completionBlock)
    }
    
    func isEntryLikedWithBlock(indexPath: NSIndexPath?, entry: PFObject, completionBlock: (result: Bool, error: NSError?) -> Void) {
        let relation: PFRelation = entry.relationForKey("likes")
        let query: PFQuery = relation.query()
        query.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            completionBlock(result: objects!.count > 0, error: error)
        }
    }
    
    func handleDoubleTap(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell

        if (indexPath == nil) {
            NSLog("tap on table view but not on a row");
        } else if (!(cell!.isLiked)) {
            self.likeEntryWithBlock(indexPath, completionBlock: { (result, error) -> Void in
                cell?.setEntryLiked()
            })
        } else if(cell!.isLiked) {
            self.unlikeEntryWithBlock(indexPath, completionBlock: { (result, error) -> Void in
                cell?.setEntryUnliked()
            })
        }
    }
    
    func handlePress(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        
        if (indexPath == nil) {
            NSLog("tap on table view but not on a row");
        } else {
            NSLog("gestureRecognizer.state = %d", gestureRecognizer.state.rawValue);
            self.selectedIndexPath = indexPath
            self.performSegueWithIdentifier("TimelineToEntryDetail", sender: self)
        }
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
        
        self.showMoreActionSheet(self, indexPath: indexPath)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        if (scrollView.contentOffset.y == 0 ) {
//            NSLog("scrolled to the top")
//            self.showTraits()
//        } else {
//            self.hideTraits()
//        }
    }
    
    func hideTraits() {
//        let pvc = self.parentViewController as! AnimalDetailViewController
//        UIView.transitionWithView(pvc.viewIfLoaded!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
//        pvc.addMenu!.hide()
    }
    
    func showTraits() {
//        let pvc = self.parentViewController as! AnimalDetailViewController
//        UIView.transitionWithView(pvc.viewIfLoaded!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
//        pvc.addMenu!.
    }
    
    func showMoreActionSheet(sender: AnyObject, indexPath: NSIndexPath?) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
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
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(profilePhotoAction)
        optionMenu.addAction(coverPhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func showFlagActionSheet(sender: AnyObject, indexPath: NSIndexPath?) {
        
        let optionMenu = UIAlertController(title: nil, message: "Flag as", preferredStyle: .ActionSheet)
        let entryObject = self.objectAtCell(indexPath)
        
        let inappropriateAction = UIAlertAction(title: "Inappropriate", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.flagItem(entryObject!, type: "inappropriate")
            print("Marked as inappropriate")
        })
        
        let spamAction = UIAlertAction(title: "Spam", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.flagItem(entryObject!, type: "spam")
            print("Marked as spam")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(inappropriateAction)
        optionMenu.addAction(spamAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func flagItem(entryObject: PFObject, type: String) {
        let flag = PFObject(className: "Flag")
        flag["entry"] = entryObject
        flag["type"] = type
        flag["reportedBy"] = PFUser.currentUser()
        
        self.showLoader()
        flag.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
            if(success) {
                NSLog("finished saving flag")
                self.displayAlert("Thanks for letting us know!  We'll take a look right away.")
            } else {
                NSLog("error saving flag")
                self.view.dodo.error((error?.localizedDescription)!)
            }
        }
    }

    
    func showShareActionSheet(sender: AnyObject, indexPath: NSIndexPath?) {
        let image = self.imageAtCell(indexPath)!
        let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func imageAtCell(indexPath: NSIndexPath?) -> UIImage? {
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell
        let image = cell!.timelineImageView.image
        return image
    }
    
    func objectAtCell(indexPath: NSIndexPath?) -> PFObject? {
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell
        let object = cell?.entryObject
        return object
    }
    
    func deleteEntry(indexPath: NSIndexPath?) {
        let object = self.objectAtIndexPath(indexPath)
        self.showLoader()
        object?.deleteInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
            if(success) {
                NSLog("finished deleting")
                self.hideLoader()
                self.loadObjects()
            }
        })
    }
    
    func imageEditor(editor: CLImageEditor!, didFinishEdittingWithImage image: UIImage!) {
        NSLog("got new image")
        let imageFile = PFFile(data: UIImageJPEGRepresentation(image, 0.5)!)
        
        if let object = self.animalObject {
            if self.isEditingProfile {
                object.setValue(imageFile, forKey: "profilePhoto")
            } else if self.isEditingCover {
                object.setValue(imageFile, forKey: "coverPhoto")
            }
            self.showLoader()
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                NSLog("finished saving profile photo")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.animalDetailController?.loadAnimal()
                self.hideLoader()
            })
        }
        self.isEditingProfile = false
        self.isEditingCover = false
    }
    
    func setCoverPhoto(image : UIImage) {
        self.isEditingCover = true

        NSLog("launching editor")
        self.showEditor(image, delegate: self, ratios: [["value1": 2, "value2": 1]])
    }

    func setProfilePhoto(image : UIImage) {
        self.isEditingProfile = true

        NSLog("launching editor")
        
        self.showEditor(image, delegate: self, ratios: [["value1": 1, "value2": 1]])
    }
    
    func incrementIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        var nextIndexPath: NSIndexPath?
        let nextRow = indexPath.row - 1
        let currentSection = indexPath.section
        
        nextIndexPath = NSIndexPath(forRow: nextRow, inSection: currentSection)
        
        return nextIndexPath
    }
    
    func animalDeceased() -> Bool {
        return self.animalObject?.valueForKey("deceasedDate") != nil
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        
        query.orderByDescending("date")
        if self.animalDeceased() {
            query.orderByAscending("date")
        }
        query.includeKey("shelter")
        query.includeKey("animal")
        if(self.animalObject != nil) {
            query.whereKey("animal", equalTo: animalObject!)
        }
        return query
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalTimelineCell", forIndexPath: indexPath) as? AnimalTimelineTableViewCell
        if cell == nil  {
            cell = AnimalTimelineTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalTimelineCell", type: object?["type"] as! String)
        }
        
        cell!.indexPath = indexPath
        cell!.parentTable = self
        cell!.entryObject = object
        cell!.type = object?["type"] as? String
        
        let animal = object?["animal"] as? PFObject
        let owner = animal?.valueForKey("owner") as? PFUser
        let currentUser = PFUser.currentUser()
        
        let currentUserIsOwner = (currentUser?.objectId == owner?.objectId)

        if(cell!.type == "image") {
            cell!.showAllButtons()

            if(currentUserIsOwner) {
                cell!.moreButton.hidden = false
                cell!.moreButton.enabled = true
                cell!.flagButton.hidden = true
                cell!.flagButton.enabled = false
            } else {
                cell!.moreButton.hidden = true
                cell!.moreButton.enabled = false
                cell!.flagButton.hidden = false
                cell!.flagButton.enabled = true
            }
            
            NSLog("setting up row: \(indexPath.row)")
            
            self.isEntryLikedWithBlock(cell!.indexPath, entry: object!, completionBlock: { (result, error) -> Void in
                if(result) {
                    cell!.setEntryLiked()
                } else {
                    cell!.setEntryUnliked()
                }
            })
            
            self.likeCountWithBlock(cell!.indexPath, entry: object!, completionBlock: { (count, error) -> Void in
                cell!.setLikeCount(count)
            })
        } else {
            cell!.hideAllButtons()
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
            switch object?["type"] as! String {
                case "medical":
                    cell!.largeIcon.image = UIImage(named: "timeline_medical")
                    cell!.largeIcon.hidden = false
                    break
                case "adopted":
                    cell!.largeIcon.image = UIImage(named: "timeline_adopted")
                    cell!.largeIcon.hidden = false
                    break
                case "birth":
                    cell!.largeIcon.image = UIImage(named: "timeline_born")
                    cell!.largeIcon.hidden = false
                    break
                case "birthday":
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
        
        if let location = object?.objectForKey("location") as? PFObject {
            cell!.locationButton.titleLabel?.textAlignment = .Center
            cell!.locationButton.setTitle(location.valueForKey("name") as? String, forState: .Normal)
            cell!.locationButton.hidden = false
        } else {
            cell!.locationButton.setTitle("", forState: .Normal)
        }
        
        if(object?.objectForKey("hasDocuments") != nil && object?.objectForKey("hasDocuments") as! Bool) {
            cell!.documentsButton.hidden = false
        } else {
            cell!.documentsButton.hidden = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "TimelineToEntryDetail") {
//            let nav = segue.destinationViewController as! UINavigationController
//            let detailScene =  nav.topViewController as! TimelineEntryDetailViewController
            let detailScene =  segue.destinationViewController as! TimelineEntryDetailViewController

            detailScene.entryObject = self.objectAtIndexPath(self.selectedIndexPath)
        }
    }
    
}
