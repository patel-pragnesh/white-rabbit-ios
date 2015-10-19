
//
//  TraitSelectorTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/28/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class TraitSelectorTableViewController: PFQueryTableViewController {

    var animalViewController : AnimalDetailViewController?
    var selectedTraitObjects : [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByAscending("name")
        return query
    }

    @IBAction func saveTraits(sender: UIBarButtonItem) {
        let selectedIndexes = self.tableView.indexPathsForSelectedRows
        
        var selectedObjects:[PFObject?] = []
        
        for indexPath in selectedIndexes! {
            selectedObjects += [self.objectAtIndexPath(indexPath)]
        }
        
        self.animalViewController?.saveTraits(selectedObjects)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelSelection(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
//        self.selectTraits()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.dequeueReusableCellWithIdentifier("TraitCell", forIndexPath: indexPath) as UITableViewCell!
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
//        cell!.selectionStyle = .None
        
//        if (cell!.accessoryType == UITableViewCellAccessoryType.Checkmark){
//            NSLog("unselected")
//            cell!.accessoryType = .None
//        } else {
//            NSLog("selected")
//            cell!.accessoryType = .Checkmark
//        }
        
//        cell!.textLabel?.text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
    }
    
    func getTraitNamesArray() -> [String]? {
        var traitNames:[String]? = []
        let traitObjects = selectedTraitObjects as [PFObject]?
        
//        NSLog("trait objects: \(traitObjects)")
        
        for traitObject in traitObjects! {
            let name = traitObject.valueForKey("name") as! String
            traitNames?.append(name)
        }
        
        return traitNames
    }
    
    func selectTraits() {
        NSLog("num sections: \(self.tableView.numberOfSections)")
        for var j = 0; j < self.tableView.numberOfSections; ++j {
            NSLog("num rows: \(self.tableView.numberOfRowsInSection(j))")
            for var i = 0; i < self.tableView.numberOfRowsInSection(j); ++i {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: j))
                cell
                NSLog("selecting cell: \(cell?.textLabel?.text)")
            }
        }
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
//        
//        let name = object?.valueForKey("name") as! String?
//        
//        let cell = PFTableViewCell()
//        cell.textLabel?.text = name
//        
//        let traitNames = self.getTraitNamesArray()
//        if ((traitNames?.contains(name!)) != nil) {
//            NSLog("contains \(name)")
//            cell.selected = true
//        }
//        
//        return cell
//    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCellWithIdentifier("TraitCell", forIndexPath: indexPath)
//
////        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
//        
//        let traitNames = getTraitNamesArray() as [String]?
//        let cellTraitName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text as String?
//        
//        NSLog("traits: \(traitNames)")
//        NSLog("cell trait: \(cellTraitName)")
//        
////        if (traitNames!.contains(cellTraitName!)) {
////            cellselected = true
////        }
//
//        return cell
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
