//
//  PostsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import SwiftDate
import ActiveLabel

class PostsTableViewCell: PFTableViewCell {
    @IBOutlet weak var usernameLink: UIButton!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var profilePhotoThumbnailView: UIButton!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UIButton!
    
    var entryObject : PFObject?
}

class PostsNavigation : UINavigationController {
    override func viewDidLoad() {
    }
}


class PostsTableViewController: PFQueryTableViewController {

    var selectedIndexPath : NSIndexPath?
    
    var hashtag : String?
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
        self.showLoader()
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        self.hideLoader()
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    @IBAction func usernamePressed(sender: AnyObject) {
        self.setSelectedIndexPathFromSender(sender)
        self.performSegueWithIdentifier("PostsToAnimalDetail", sender: sender)
    }
    
    func showEntryDetail(gestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = gestureRecognizer.view!
        self.setSelectedIndexPathFromSender(tappedImageView)
        self.performSegueWithIdentifier("PostsToEntryDetail", sender: tappedImageView)
    }
    
    func objectAtCell(indexPath: NSIndexPath?) -> PFObject? {
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? PostsTableViewCell
        let object = cell?.entryObject
        return object
    }
    
    func setSelectedIndexPathFromSender(sender: AnyObject) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        self.selectedIndexPath = indexPath
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y - 600 < (self.view.bounds.size.height) {
            if !self.loading {
                self.loadNextPage()
            }
        }
    }
        
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as? PostsTableViewCell
        cell?.hidden = true
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylePFLoadingView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(self.hashtag != nil) {
            self.setUpNavigationBar("#\(self.hashtag!)")
        } else {
            self.setUpMenuBarController("Feed")
        }
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        query.whereKey("type", equalTo: "image")
        if(self.hashtag != nil) {
            query.whereKey("text", containsString: "#\(self.hashtag!)")
        }
        query.whereKey("private", equalTo: false)
        query.includeKey("animal")
        return query
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.selectedIndexPath = indexPath
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as? PostsTableViewCell
        
        if cell == nil  {
            cell = PostsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PostCell")
        }
        
        cell!.entryObject = object
        
        cell!.captionLabel.handleHashtagTap { (hashtag: String) -> () in
            if(hashtag != self.hashtag) {
                self.openHashTagFeed(hashtag)
            }
        }
        cell!.captionLabel.handleMentionTap(self.openAnimalDetail)
        
        // Extract values from the PFObject to display in the table cell
        // cell!.name.text = object?["name"] as? String
                
        let imageFile = object?["image"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.largeImageView.image = image
                
                cell!.largeImageView.userInteractionEnabled = true
                let tapRecognizer = UITapGestureRecognizer(target: self, action: "showEntryDetail:")
                cell!.largeImageView.addGestureRecognizer(tapRecognizer)
            }
        })
        
        if let date = object!.valueForKey("createdAt") as? NSDate {
            let formatted = date.toRelativeString(fromDate: NSDate(), abbreviated: true, maxUnits:1)
            cell!.timeLabel.setTitle(formatted, forState: .Normal)
        }
        
        if let text = object?["text"] as? String {
            cell!.captionLabel.text = text
            cell!.captionLabel.hidden = false
        } else {
            cell!.captionLabel.text = ""
            cell!.captionLabel.hidden = true
        }
        
        
        let animalObject = object?.objectForKey("animal") as? PFObject
        cell!.usernameLink.setTitle(animalObject!.valueForKey("username") as? String, forState: .Normal)
        
        if let profilePhotoFile = animalObject!["profilePhoto"] as? PFFile {
            profilePhotoFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.profilePhotoThumbnailView.setImage(image?.circle, forState: .Normal)
                }
            })
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "PostsToAnimalDetail") {
            let detailScene =  segue.destinationViewController as! AnimalDetailViewController
            let entry : PFObject = self.objectAtIndexPath(self.selectedIndexPath)!
            detailScene.currentAnimalObject = entry.valueForKey("animal") as? PFObject
        } else if(segue.identifier == "PostsToEntryDetail") {
            let detailScene =  segue.destinationViewController as! TimelineEntryDetailViewController
            detailScene.entryObject = self.objectAtIndexPath(self.selectedIndexPath)
        }

    }
    
}
