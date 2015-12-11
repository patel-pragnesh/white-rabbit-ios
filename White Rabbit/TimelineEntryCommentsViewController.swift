//
//  TimelineEntryCommentsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/5/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ActiveLabel
import BGTableViewRowActionWithImage

class TimelineEntryCommentViewCell: PFTableViewCell {
    var commentObject: PFObject?
    
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
}

class TimelineEntryCommentsViewController: PFQueryTableViewController {

    var entryObject : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylePFLoadingView()
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Comment")
        
        query.orderByDescending("date")
        query.includeKey("entry")
        query.includeKey("animal")
        if(self.entryObject != nil) {
            query.whereKey("entry", equalTo: entryObject!)
        }
        return query
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? TimelineEntryCommentViewCell
        
        let animal = entryObject!["animal"] as? PFObject
        let owner = animal?.valueForKey("owner") as? PFUser
        
        if(PFUser.currentUser()?.objectId == owner?.objectId) {
            let remove = BGTableViewRowActionWithImage.rowActionWithStyle(.Normal, title: "Remove", backgroundColor: UIColor.redColor(), image: UIImage(named: "remove_white")!, forCellHeight: UInt((cell?.frame.height)!)) { action, index in
                self.removeComment(indexPath)
            }
            
            return [remove]
        } else {
            let flag = BGTableViewRowActionWithImage.rowActionWithStyle(.Normal, title: "Flag", backgroundColor: UIColor.lightGrayColor(), image: UIImage(named: "flag_white")!, forCellHeight: UInt((cell?.frame.height)!)) { action, index in
                self.showFlagActionSheet(tableView, indexPath: indexPath, flaggedObject: self.objectAtCell(indexPath)!)
                self.tableView.setEditing(false, animated: true)
            }

            return [flag]
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as? TimelineEntryCommentViewCell
        if cell == nil  {
            cell = TimelineEntryCommentViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CommentCell")
        }
        
        cell!.autoresizingMask = UIViewAutoresizing.None
        cell!.autoresizesSubviews = false
        
        cell!.commentObject = object
        
        cell!.commentLabel.text = object?.valueForKey("text") as? String
        cell!.commentLabel.handleHashtagTap(self.openHashTagFeed)
        cell!.commentLabel.handleMentionTap(self.openAnimalDetail)

        if let date = object!.valueForKey("createdAt") as? NSDate {
            let formatted = date.toRelativeString(fromDate: NSDate(), abbreviated: true, maxUnits:1)
            cell!.timeLabel.text = formatted
        }
        
        let animalObject = object?.objectForKey("animal") as? PFObject
        cell!.usernameButton.setTitle(animalObject!.valueForKey("username") as? String, forState: .Normal)
        
        if let profilePhotoFile = animalObject!["profilePhoto"] as? PFFile {
            profilePhotoFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.profilePhotoButton.setImage(image?.circle, forState: .Normal)
                }
            })
        }
        
        
        return cell
    }
    
    func removeComment(indexPath: NSIndexPath) {
        let comment = objectAtCell(indexPath)
        comment?.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if(error == nil) {
                NSLog("removed comment")
                self.tableView.setEditing(false, animated: true)
                self.loadObjects()
            } else {
                self.showError(error!.localizedDescription)
            }
        })
    }
    
    func objectAtCell(indexPath: NSIndexPath?) -> PFObject? {
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? TimelineEntryCommentViewCell
        let object = cell?.commentObject
        return object
    }

    
}
