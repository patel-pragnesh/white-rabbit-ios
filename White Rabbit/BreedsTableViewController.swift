//
//  BreedsTable.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class BreedsTableViewCell: PFTableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
}

class BreedsTableViewController: PFQueryTableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "Breed"
        self.paginationEnabled = false
        self.pullToRefreshEnabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        tableView.reloadData()
//        self.searchBar.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.searchBar.hidden = true
        
        self.setUpMenuBarController("Breeds")
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("search_white", action: "showSearch", height: 25)

    }
    
    func showSearch() {
        if (self.searchBar.hidden) {
            self.searchBar.hidden = false
        } else {
            self.searchBar.hidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // Force reload of table data
        self.loadObjects()

    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
//        if searchBar.text != "" {
//            query.whereKey("name", containsString: searchBar.text!)
//        }
        query.orderByAscending("name")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("BreedCell", forIndexPath: indexPath) as? BreedsTableViewCell
        
        if cell == nil  {
            cell = BreedsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "BreedCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        cell!.name.text = object?["name"] as? String
        
        if let imageFile = object?["image"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.thumbnailImage.image = image
                }
            })
        } else {
            cell!.thumbnailImage.image = nil
        }
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        NSLog("selected cell #\(indexPath.row)!")
//        self.performSegueWithIdentifier("bd_segue", sender: tableView)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {        
        // Get the new view controller
        let detailScene = segue.destinationViewController as! BreedDetailViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let row = Int(indexPath.row)
            let object = objects?[row] as! PFObject
            
            NSLog("Viewing detail for object: %@\n", object)
            detailScene.currentBreedObject = object
        }
    }
}
