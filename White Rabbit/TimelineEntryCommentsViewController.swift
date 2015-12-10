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

class TimelineEntryCommentViewCell: PFTableViewCell {
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
}

class TimelineEntryCommentsViewController: PFQueryTableViewController {

    var entryObject : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as? TimelineEntryCommentViewCell
        if cell == nil  {
            cell = TimelineEntryCommentViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CommentCell")
        }
        
        cell!.commentLabel.text = object?.valueForKey("text") as? String
        
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
    
}
