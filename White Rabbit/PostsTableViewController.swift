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
import InstagramKit

class PostsTableViewController: PFQueryTableViewController {

    var engine : InstagramEngine
    
    required init(coder aDecoder:NSCoder) {
        self.engine = InstagramEngine.sharedEngine()

        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylePFLoadingView()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        query.includeKey("user")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as? PostsTableViewCell
        
        if cell == nil  {
            cell = PostsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PostCell")
        }
        
        
        // Extract values from the PFObject to display in the table cell
        // cell!.name.text = object?["name"] as? String
                
        let imageFile = object?["image"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.largeImageView.image = image
            }
        })
        
        let userObject = object?.objectForKey("user") as? PFObject
        cell!.usernameLink.setTitle(userObject!.valueForKey("firstName") as? String, forState: .Normal)
        
        return cell
    }
    
}
