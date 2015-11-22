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
    @IBOutlet weak var shelterButton: UIButton!
    @IBOutlet weak var largeIcon: UIImageView!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var indexPath: NSIndexPath?
    var parentTable: AnimalTimelineTableViewController?
    var type: String?
    
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
        self.moreButton.hidden = false
    }
    
    func hideAllButtons() {
        self.heartButton.hidden = true
        self.commentButton.hidden = true
        self.shareButton.hidden = true
        self.moreButton.hidden = true
    }

    @IBAction func heartButtonPressed(sender: AnyObject) {
        parentTable?.likeEntry(self.indexPath!)
    }
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        parentTable!.selectedIndexPath = self.indexPath!
        parentTable!.performSegueWithIdentifier("TimelineToEntryDetail", sender: self)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        parentTable!.showShareActionSheet(sender, indexPath: self.indexPath!)
    }
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        parentTable!.showMoreActionSheet(sender, indexPath: self.indexPath!)
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
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureRecognizer.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(gestureRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handlePress:")
        self.tableView.addGestureRecognizer(tapRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.tableView.addGestureRecognizer(doubleTapRecognizer)

    }
    
    func likeEntry(indexPath: NSIndexPath?) {
        NSLog("Entry has been liked!")
    }
    
    func handleDoubleTap(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        
        if (indexPath == nil) {
            NSLog("tap on table view but not on a row");
        } else {
            NSLog("gestureRecognizer.state = %d", gestureRecognizer.state.rawValue);
            self.likeEntry(indexPath)
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
    
    func deleteEntry(indexPath: NSIndexPath?) {
        let object = self.objectAtIndexPath(indexPath)
        object?.deleteInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
            if(success) {
                NSLog("finished deleting")
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
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                NSLog("finished saving profile photo")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.animalDetailController?.loadAnimal()
            })
        }
        self.isEditingProfile = false
        self.isEditingCover = false
    }
    
    func setCoverPhoto(image : UIImage) {
        self.isEditingCover = true

        NSLog("launching editor")
        self.showEditor(image)
    }

    func setProfilePhoto(image : UIImage) {
        self.isEditingProfile = true

        NSLog("launching editor")
        self.showEditor(image)
    }
    
    func showEditor(image : UIImage) {
        let editor = CLImageEditor(image: image)
        editor.delegate = self
        
        let curveTool = editor.toolInfo.subToolInfoWithToolName("CLToneCurveTool", recursive: false)
        curveTool.available = false
        let blurTool = editor.toolInfo.subToolInfoWithToolName("CLBlurTool", recursive: false)
        blurTool.available = false
        let drawTool = editor.toolInfo.subToolInfoWithToolName("CLDrawTool", recursive: false)
        drawTool.available = false
        let adjustmentTool = editor.toolInfo.subToolInfoWithToolName("CLAdjustmentTool", recursive: false)
        adjustmentTool.available = false

        let effectTool = editor.toolInfo.subToolInfoWithToolName("CLEffectTool", recursive: false)
        effectTool.available = true
        let pixelateFilter = effectTool.subToolInfoWithToolName("CLPixellateEffect", recursive: false)
        pixelateFilter.available = false
        let posterizeFilter = effectTool.subToolInfoWithToolName("CLPosterizeEffect", recursive: false)
        posterizeFilter.available = false

        
        let filterTool = editor.toolInfo.subToolInfoWithToolName("CLFilterTool", recursive: false)
        filterTool.available = true
        let invertFilter = filterTool.subToolInfoWithToolName("CLDefaultInvertFilter", recursive: false)
        invertFilter.available = false
        
        let rotateTool = editor.toolInfo.subToolInfoWithToolName("CLRotateTool", recursive: false)
        rotateTool.available = true
        rotateTool.dockedNumber = -1
        
        let cropTool = editor.toolInfo.subToolInfoWithToolName("CLClippingTool", recursive: false)
        cropTool.available = true
        cropTool.dockedNumber = -2
        cropTool.optionalInfo["swapButtonHidden"] = true
        
        var ratios: [AnyObject] = [["value1": 1, "value2": 1]]
        if self.isEditingCover {
            ratios = [["value1": 2, "value2": 1]]
        } else if self.isEditingProfile {
            ratios = [["value1": 1, "value2": 1]]
        }
        cropTool.optionalInfo["ratios"] = ratios
        
        self.presentViewController(editor, animated: true, completion: nil)
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
        if(self.animalObject != nil) {
            query.whereKey("animal", equalTo: animalObject!)
        }
        return query
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
        
        cell!.hideAllButtons()
        if(cell!.type == "image") {
            cell!.showAllButtons()
        }

        
        cell!.timelineImageView.hidden = true
        if let imageFile = object?["image"] as? PFFile {
            NSLog("setting cell image")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "TimelineToEntryDetail") {
//            let nav = segue.destinationViewController as! UINavigationController
//            let detailScene =  nav.topViewController as! TimelineEntryDetailViewController
            let detailScene =  segue.destinationViewController as! TimelineEntryDetailViewController

            detailScene.entryObject = self.objectAtIndexPath(self.selectedIndexPath)
        }
    }
    
}
