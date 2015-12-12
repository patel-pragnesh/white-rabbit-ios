//
//  CatsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import BTNavigationDropdownMenu

class AnimalsTableViewCell: PFTableViewCell {
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
}

class AnimalsTableViewController: PFQueryTableViewController {

    var owner : PFUser?
    var adoptable : Bool = false
    var featured : Bool = false
    var shelter : PFObject?
    
    var locationDetailController : LocationDetailViewController?
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = "Add a cat"
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let text: String = "You haven't added a cat yet."
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(14.0), NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> NSAttributedString {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17.0)]
        return NSAttributedString(string: "Add a Cat", attributes: attributes)
    }
    
    func buttonImageForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> UIImage {
        return UIImage(named: "cat_add_black")!
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView) {
        self.showAddAminalView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylePFLoadingView()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        if self.shelter == nil {
//            let items = ["Mine", "Featured", "Adoptable"]
//            let menuView = BTNavigationDropdownMenu(title: items.first!, items: items, nav: self.navigationController!)
//            menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
//                print("Did select item at index: \(indexPath)")
//                self.setCurrentView(items[indexPath])
//            }
//            menuView.menuTitleColor = UIColor.whiteColor()
//            menuView.cellTextLabelColor = UIColor.whiteColor()
//            menuView.cellBackgroundColor = UIColor.darkGrayColor()
//            self.navigationItem.titleView = menuView
//            menuView.reloadInputViews()
            
//            self.setCurrentUser()
            
//            self.setUpMenuBarController()
        } else {
            //            let shelterName = self.shelter!["name"] as? String
            //            self.setUpNavigationBar(shelterName!)
        }
        
        if self.owner != nil {
            self.navigationItem.rightBarButtonItem = self.getNavBarItem("add_white", action: "showAddAminalView", height: 25, width: 25)
        }
    }
    
    override func queryForTable() -> PFQuery {
        NSLog("queryForTable: " + self.parseClassName!)
        let query = PFQuery(className: self.parseClassName!)
        if self.owner != nil {
            NSLog("query for: \(owner)")
            query.whereKey("owner", equalTo: owner!)
        }
        if self.featured {
            query.whereKey("featured", equalTo: true)
            query.whereKey("adoptable", equalTo: false)
        }
        if self.adoptable {
            query.whereKey("featured", equalTo: true)
            query.whereKey("adoptable", equalTo: true)
        }
        if self.shelter != nil {
            query.whereKey("shelter", equalTo: self.shelter!)
            query.whereKey("adoptable", equalTo: true)
        }
        query.orderByAscending("name")
        query.includeKey("breed")
        query.includeKey("coat")
        query.includeKey("shelter")
        query.includeKey("owner")
        return query
    }
    
    func setCurrentUser() {
        let menuViewController = self.slideMenuController()?.leftViewController as! HomeViewController
        let user = menuViewController.currentUser as PFUser?
        NSLog("found user \(user)")
        if user != nil {
            self.owner = user!
        }
    }
    
    func setCurrentView(viewName: String) {
        switch viewName {
            case "Featured":
                self.featured = true
                self.owner = nil
                self.adoptable = false
                break
            case "Adoptable":
                self.featured = false
                self.owner = nil
                self.adoptable = true
                break
            case "Mine":
                self.featured = false
                self.adoptable = false
                self.setCurrentUser()
                break
            default:
                break
        }
//        self.loader = self.showLoader()
        self.loadObjects()
        self.hideLoader()
    }
    
    func showAddAminalView() {
        self.performSegueWithIdentifier("AnimalTableToAddAnimal", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        if self.shelter != nil {
//            let shelterName = self.shelter!["name"] as? String
//            self.setUpNavigationBar(shelterName!)
//        } else {
//            self.setUpNavigationBar()
//        }
//        self.setUpMenuBarController("Animals")
//        self.setUpNavigationBar("Animals")
        
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if(self.locationDetailController != nil) {
//            self.performSegueWithIdentifier("AnimalTableToAnimalDetail", sender: tableView)
//        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AnimalCell", forIndexPath: indexPath) as? AnimalsTableViewCell
        
        if cell == nil  {
            cell = AnimalsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AnimalCell")
        }
        
        cell!.nameLabel.text = object?["name"] as? String
        
        cell!.coverPhoto.image = UIImage(named: "blank_cover")
        let coverPhotoFile = object?["coverPhoto"] as? PFFile
        coverPhotoFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.coverPhoto.image = image
            }
        })
        
        cell!.profilePhoto.image = UIImage(named: "avatar_blank")
        let profilePhotoFile = object?["profilePhoto"] as? PFFile
        profilePhotoFile?.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                cell!.profilePhoto.image = image?.circle
            }
        })
        
        return cell
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "AnimalTableToAnimalDetail") {
            // Get the new view controller
            let detailScene = segue.destinationViewController as! AnimalDetailViewController
            
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                let object = objects?[row] as! PFObject
                
                detailScene.currentAnimalObject = object
            }
        } else if(segue.identifier == "AnimalTableToAddAnimal") {
            let editScene = (segue.destinationViewController as! UINavigationController)
            let formScene = editScene.viewControllers[0] as! AnimalFormViewController
            formScene.animalTableController = self
            formScene.userObject = self.owner
        }
    }
}
