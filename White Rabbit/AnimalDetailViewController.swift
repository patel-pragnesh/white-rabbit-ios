//
//  CatDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
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
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var instagramView: UIView!
    
    var currentAnimalObject : PFObject?
    var breedObject : PFObject?
    var traitObjects : [PFObject?] = []
    var timelineTableController : AnimalTimelineTableViewController?
    
    var instagramTableController : InstagramTableViewController?
    var instagramUsername : String?
    
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
        
//        self.setUpNavigationBar()
        
//        self.timelineTableController!.loadObjects()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default
        )
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
    }
    
    func showEditAminalView() {
        self.performSegueWithIdentifier("AnimalDetailToEditAnimal", sender: self)
    }
    
//    func showInstagramView(instagramId: String) {
//        let view = self.instagramView as! InstagramTableViewController
//        view.userId = instagramId
//        view.loadMedia()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.instagramView.hidden = false
        self.timelineView.hidden = false
        
        let timelineTableController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalTimelineTable") as! AnimalTimelineTableViewController
        timelineTableController.animalObject = self.currentAnimalObject
        self.timelineTableController = timelineTableController
        
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("setting_white", action: "showEditAminalView", height: 25)
        
        traitTags.textFont = UIFont.systemFontOfSize(15)
        
        self.loadAnimal()
    }
    
    func loadAnimal() {
        if let object = currentAnimalObject {
            //            NSLog("Viewing detail for object: %@\n", object)
            
            nameLabel.text = object["name"] as? String
            genderLabel.text = object["gender"] as? String
            let birthDate = object["birthDate"] as? NSDate
            let deceasedDate = object["deceasedDate"] as? NSDate
            if(birthDate != nil) {
                ageLabel.text = getAgeString(birthDate!, deceasedDate: deceasedDate)
            } else {
                ageLabel.text = "Age Unknown"
            }
            
            let instagramUsername = object["instagramUsername"] as? String
            if(instagramUsername != nil) {
                NSLog("setting instagram: \(instagramUsername)")
                self.instagramUsername = instagramUsername!
                
                self.instagramTableController?.userName = instagramUsername!
                self.instagramTableController?.loadMedia()
                //                self.instagramTableController?.loadView()
                
                self.instagramView.hidden = false
                self.timelineView.hidden = true
                
            } else {
                self.instagramView.hidden = true
                self.timelineView.hidden = false
            }
            
            //            self.navigationItem.title = object["username"] as? String
            
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
                        self.profileThumb.image = image?.circle
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
    
    func getAgeString(birthDate: NSDate, deceasedDate: NSDate?) -> String {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var ageString = ""
        
        if (deceasedDate != nil) {
            let ageComponents = calendar.components(.Year, fromDate: birthDate)
            let ageDeathComponents = calendar.components(.Year, fromDate: deceasedDate!)
            ageString = ageComponents.year.description + " - " + ageDeathComponents.year.description
        } else {
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
                        self.traitObjects.append(object)
                    }
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "AnimalToBreedDetail") {
            let detailScene = segue.destinationViewController as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        } else if(segue.identifier == "AnimalDetailToEditAnimal"){
            let nav = segue.destinationViewController as! UINavigationController
            let editScene =  nav.topViewController as! AnimalFormViewController
            editScene.detailController = self
            editScene.animalObject = self.currentAnimalObject        
        } else if(segue.identifier == "AnimalToTraitSelector") {
            let traitSelector = segue.destinationViewController as! TraitSelectorTableViewController
            NSLog("trait objects before: \(self.traitObjects)")
            traitSelector.selectedTraitObjects = self.traitObjects
            traitSelector.animalViewController = self
        } else if(segue.identifier == "AnimalDetailToTimeline" || segue.identifier == "AnimalDetailTimelineEmbed") {
            let animalTimeline = segue.destinationViewController as! AnimalTimelineTableViewController
            animalTimeline.animalObject = self.currentAnimalObject
        } else if(segue.identifier == "AnimalDetailToAddTimelineEntry") {
            let camera = segue.destinationViewController as! CameraViewController
            camera.animalDetailController = self
            camera.animalObject = self.currentAnimalObject
        } else if (segue.identifier == "AnimalDetailInstagramEmbed") {
            if(self.instagramUsername != nil) {
                NSLog("showing insta view")
                
                self.instagramView.hidden = false
                self.timelineView.hidden = true
            } else {
                NSLog("Insta wasn't set yet")
                let insta = segue.destinationViewController as! InstagramTableViewController
                self.instagramTableController = insta
            }
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
    
    @IBAction func closeScreen(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openTwitterProfile(sender: AnyObject) {
        let twitterUsername = self.currentAnimalObject?.objectForKey("twitterUsername") as? String
        
        let twitterAppLink = "twitter://user?screen_name=" + twitterUsername!
        let twitterWebLink = "http://twitter/" + twitterUsername!
        
        openAppLinkOrWebUrl(twitterAppLink, webUrl: twitterWebLink)
    }
    
}