//
//  CatDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import XLForm
import TagListView

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var traitTags: TagListView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileThumb: UIImageView!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!

    var currentAnimalObject : PFObject?
    var breedObject : PFObject?
    var traitObjects : [PFObject]? = []
    
//    @IBAction func viewBreedDetail(sender: UIButton) {
//        NSLog("viewing breed detail")
//        self.performSegueWithIdentifier("AnimalToBreedDetail", sender: self)
//    }
    
    func saveTraits(traitObjects: [PFObject?]) {
        let relation = self.currentAnimalObject?.relationForKey("traits")
        
        // clear out all previous traits
        // TODO - figure out a more efficient way to do this
        let traitsQuery = PFQuery(className: "Trait")
        let allTraits = try! traitsQuery.findObjects()
        for traitObject in allTraits {
            relation?.removeObject(traitObject)
        }
            
        for traitObject in traitObjects {
            print("adding: \(traitObject)!")
            relation?.addObject(traitObject!)
        }
        
        self.currentAnimalObject?.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            self.addTraitTags()
        })
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
//        let timelineTableController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalTimelineTable")
//        timelineTableController?.view.layoutIfNeeded()
//        var subviewsHeight:CGFloat = 0
//        for view in timelineTableController!.view.subviews {
//            subviewsHeight += view.bounds.height
//            NSLog("view: \(view.description)")
//        }
//        
//        let tableHeight = (timelineTableController?.view.frame.size.height)!
//        let viewHeight = timelineContainerView.frame.size.height
//
//        NSLog("table height: \(tableHeight)")
//        NSLog("view height: \(viewHeight)")
//        
//        timelineContainerView.frame.size.height = tableHeight
        
//        timelineContainerView.frame.size.height = tableHeight// subviewsHeight
//        timelineTableController?.view.frame.size.height
//        timelineContainerView.sizeToFit()
//        timelineContainerView.reloadInputViews()
//        self.view.layoutIfNeeded()
//        self.view.sizeToFit()
        
//        let newViewHeight = timelineContainerView.frame.size.height
//        NSLog("new view height: \(newViewHeight)")
        
    }
    
    func showEditAminalView() {
        displayAlert("editing")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.hidden = false
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let editImage = UIImage(named: "edit_white")
        let editButton = UIButton(type: .Custom)
        editButton.setImage(editImage, forState: .Normal)
        editButton.frame = CGRectMake(0, 0, 25, 25)
        editButton.addTarget(self, action: "showEditAminalView", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        traitTags.textFont = UIFont.systemFontOfSize(15)
        
        if let object = currentAnimalObject {
//            NSLog("Viewing detail for object: %@\n", object)
            
            nameLabel.text = object["name"] as? String
            genderLabel.text = object["gender"] as? String
            let birthDate = object["birthDate"] as? NSDate
            if(birthDate != nil) {
                ageLabel.text = getAgeString(birthDate!)
            } else {
                ageLabel.text = "Age Unknown"
            }
            
            self.navigationItem.title = object["username"] as? String
            
            if let coverPhotoFile = object["coverPhoto"] as? PFFile {
                coverPhotoFile.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.coverPhoto.image = image
                    }
                })
            }
            
//            profileThumb.layer.cornerRadius = profileThumb.frame.size.width / 2
//            profileThumb.clipsToBounds = true
            
            if let profilePhotoFile = object["profilePhoto"] as? PFFile {
                profilePhotoFile.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.profileThumb.image = image
                    }
                })
            }
            
            self.addTraitTags()
            
            self.breedObject = object.objectForKey("breed") as? PFObject
            if self.breedObject != nil {
                breedButton.setTitle(self.breedObject!.valueForKey("name") as? String, forState: .Normal)
            } else {
                breedButton.hidden = true
            }

            if(object.objectForKey("instagramUsername") == nil) {
                instagramButton.hidden = true
            }
            if(object.objectForKey("facebookPageId") == nil) {
                facebookButton.hidden = true
            }
            if(object.objectForKey("youtubeUsername") == nil) {
                youtubeButton.hidden = true
            }
            if(object.objectForKey("twitterUsername") == nil) {
                twitterButton.hidden = true
            }

        
        }
    }
    
    func getAgeString(birthDate: NSDate) -> String {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var ageString = ""
        
        let ageComponents = calendar.components(.Year,
            fromDate: birthDate,
            toDate: now,
            options: [])
        
        if ageComponents.year < 2 {
            let ageComponentsMonth = calendar.components(.Month,
                fromDate: birthDate,
                toDate: now,
                options: [])

            ageString = String(ageComponentsMonth.month) + " months old"
        } else {
            ageString = String(ageComponents.year) + " years old"
        }
        
        return ageString
    }
    
    func addTraitTags() {
        if let animalObject = currentAnimalObject {
            let traitsRelation = animalObject["traits"] as! PFRelation
            let traitsQuery = traitsRelation.query() as PFQuery?

            self.traitTags.removeAllTags()
            traitsQuery?.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        let name = object.objectForKey("name") as! String
                        self.traitTags.addTag(name)
                        self.traitObjects?.append(object)
                    }
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "AnimalToBreedDetail") {
            let detailScene = segue.destinationViewController as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        } else if(segue.identifier == "AnimalToTraitSelector") {
            let traitSelector = segue.destinationViewController as! TraitSelectorTableViewController
            NSLog("trait objects before: \(self.traitObjects)")
            traitSelector.selectedTraitObjects = self.traitObjects
            traitSelector.animalViewController = self
        }
    }
    
    
    @IBAction func openInstagramProfile(sender: AnyObject) {
        let instagramUsername = self.currentAnimalObject?.objectForKey("instagramUsername") as? String
        
        let instagramAppLink = "instagram://user?username=" + instagramUsername!
        let instagramWebLink = "http://instagram.com/" + instagramUsername!
        
        openAppLinkOrWebUrl(instagramAppLink, webUrl: instagramWebLink)
    }
    
    @IBAction func openFacebookProfile(sender: AnyObject) {
        let facebookId = self.currentAnimalObject?.objectForKey("facebookPageId") as? String

        let facebookAppLink = "fb://page?id=" + facebookId!
        let facebookWebLink = "http://facebook.com/" + facebookId!
        
        openAppLinkOrWebUrl(facebookAppLink, webUrl: facebookWebLink)
    }
    
    @IBAction func openYoutubeProfile(sender: AnyObject) {
        let youtubeUsername = self.currentAnimalObject?.objectForKey("youtubeUsername") as? String
        
        let youtubeAppLink = "youtube://www.youtube.com/user/" + youtubeUsername!
        let youtubeWebLink = "http://youtube.com/user/" + youtubeUsername!
        
        openAppLinkOrWebUrl(youtubeAppLink, webUrl: youtubeWebLink)
    }
    
    @IBAction func openTwitterProfile(sender: AnyObject) {
        let twitterUsername = self.currentAnimalObject?.objectForKey("twitterUsername") as? String
        
        let twitterAppLink = "twitter://user?screen_name=" + twitterUsername!
        let twitterWebLink = "http://twitter/" + twitterUsername!
        
        openAppLinkOrWebUrl(twitterAppLink, webUrl: twitterWebLink)
    }
    
}