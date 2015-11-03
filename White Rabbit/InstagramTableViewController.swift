//
//  InstagramTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/9/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import InstagramKit


class InstagramTableViewController: UITableViewController {

    var engine : InstagramEngine
    var media : [AnyObject]
    var currentPaginationInfo : InstagramPaginationInfo
    var userId : String = ""
    
    required init(coder aDecoder:NSCoder) {
        self.engine = InstagramEngine.sharedEngine()
        self.media = [AnyObject]()
        self.currentPaginationInfo = InstagramPaginationInfo()
        
        super.init(coder: aDecoder)!
        
//        self.loadMedia()
    }
    
    func loadMedia() {
        NSLog("loading media for \(self.userId)\n")
        
        self.engine.getMediaForUser(self.userId, count: 10, maxId: self.currentPaginationInfo.nextMaxId, withSuccess: { (object: [AnyObject]!, pagination: InstagramPaginationInfo!) -> Void in
            self.currentPaginationInfo = pagination
            NSLog("nextMaxId: %@\n", self.currentPaginationInfo.nextMaxId)
            self.media += object!
            self.tableView.reloadData()
            self.tableView.sizeToFit()
            }, failure: { (error: NSError!, code: Int) -> Void in
                NSLog("instagram error: %@\n", error!)
            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.media.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstagramCell", forIndexPath: indexPath)

        if(self.media.count > 0) {
            let instagramPhoto = self.media[indexPath.row] as! InstagramMedia
            
            let imageUrl = instagramPhoto.standardResolutionImageURL

//            NSLog("image url: %@\n", imageUrl)
            
            if let data = NSData(contentsOfURL: imageUrl){
                cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
                cell.imageView!.image = UIImage(data: data)

//                cell.textLabel?.text = instagramPhoto.caption!.text
//                cell.textLabel?.text = instagramPhoto.link
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
//        NSLog("viewing cell: %@\n", indexPath.row)
        
        if(indexPath.row == self.media.count - 1) {
            NSLog("got to last: \(indexPath.row)")

            self.loadMedia()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let instagramPhoto = self.media[indexPath.row] as! InstagramMedia
        
        let instagramWebUrl = instagramPhoto.link
        let instagramUrl = "instagram://media?id=" + instagramPhoto.Id
        
        openAppLinkOrWebUrl(instagramUrl, webUrl: instagramWebUrl)
    }

}
