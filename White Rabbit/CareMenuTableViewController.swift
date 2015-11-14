//
//  CareMenuTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/22/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit

class CareMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
}

class CareMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpMenuBarController("Care")

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setUpMenuBarController("Care")
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CareMenuCell", forIndexPath: indexPath) as! CareMenuTableViewCell

        switch indexPath.row {
            case 0:
                cell.coverImage.image = UIImage(named: "care_menu_food")
                break
            case 1:
                cell.coverImage.image = UIImage(named: "care_menu_water")
                break
            case 2:
                cell.coverImage.image = UIImage(named: "care_menu_handling")
                break
            case 3:
                cell.coverImage.image = UIImage(named: "care_menu_hygeine")
                break
            case 4:
                cell.coverImage.image = UIImage(named: "care_menu_play")
                break
            case 5:
                cell.coverImage.image = UIImage(named: "care_menu_health")
                break
            case 6:
                cell.coverImage.image = UIImage(named: "care_menu_behavior")
                break
            default: break
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let sectionScene = segue.destinationViewController as! CareSectionViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            switch indexPath.row {
            case 0:
                sectionScene.contentId = "5ihTZT9t32KqO42yA2wqQy"
                sectionScene.headerName = "care_menu_food"
                break
            case 1:
                sectionScene.contentId = "6P7DUhTNi8cMMUWSc0W8MQ"
                sectionScene.headerName = "care_menu_water"
                break
            case 2:
                sectionScene.contentId = "3YsRKDVT32WMMWQyImwIyI"
                sectionScene.headerName = "care_menu_handling"
                break
            case 3:
                sectionScene.contentId = "XI260ffZo2qiQisUsukya"
                sectionScene.headerName = "care_menu_hygeine"
                break
            case 4:
                sectionScene.contentId = "4Blo8N2w9yAuKW8AcuCyYe"
                sectionScene.headerName = "care_menu_play"
                break
            case 5:
                sectionScene.contentId = "5U6Skz08RUMIEgyKg22IyU"
                sectionScene.headerName = "care_menu_health"
                break
            case 6:
                sectionScene.contentId = "3V6FYjkSLKGEYYGmUi2ImK"
                sectionScene.headerName = "care_menu_behavior"
                break
            default: break
            }
        }
    }

}
