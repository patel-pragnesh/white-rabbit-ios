//
//  CatDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import TagListView
import Darwin
import ALCameraViewController
import CLImageEditor
import AssetsLibrary
import PagingMenuController

class AnimalDetailViewController: UIViewController, SphereMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate, PagingMenuControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileThumb: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var shelterButton: UIButton!
    
    var currentAnimalObject : PFObject?
    var breedObject : PFObject?
    var shelterObject : PFObject?
    var username : String?
    
    var currentUserIsOwner = false
    var currentUserIsAdmin = false
    var currentUserIsShelterCaregiver = false
    
    var addMenu : SphereMenu?
    
    var aboutViewController : AnimalAboutViewController?
    var timelineTableController : AnimalTimelineTableViewController?
    var instagramTableController : InstagramTableViewController?
    
    var instagramUsername : String?
    
    var pickedImageDate : NSDate?
    
    var isSettingProfilePhoto : Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton.hidden = true
        self.timelineView.hidden = false
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        if(self.currentAnimalObject != nil) {
            self.loadAnimal()
        } else if(self.username != nil) {
            self.loadAnimalFromUsername()
        }
    }
    
    func loadAnimalFromUsername() {
        let animalQuery = PFQuery(className: "Animal")
        animalQuery.whereKey("username", equalTo: self.username!)
        animalQuery.includeKey("owner")
        animalQuery.includeKey("breed")
        animalQuery.includeKey("coat")
        animalQuery.includeKey("shelter")
        self.showLoader()
        animalQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if(error == nil) {
                let animal = objects![0]
                self.currentAnimalObject = animal
                self.loadAnimal()
                
                self.aboutViewController?.animalObject = animal
                self.aboutViewController?.loadAnimal()
                
                self.timelineTableController?.animalObject = animal
                self.timelineTableController?.loadObjects()
                self.hideLoader()
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default
        )
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
    }


    
    func reloadTimeline() {
        NSLog("relaoding timeline")
        self.timelineTableController!.loadObjects()
    }
    
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
        
        self.showLoader()
        self.currentAnimalObject?.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
        })
    }
    
    func createAddMenu() {
        let start = UIImage(named: "add_button")
        let image1 = UIImage(named: "button_camera")
        let image2 = UIImage(named: "button_photo")
        let image3 = UIImage(named: "button_medical")
        let images:[UIImage] = [image1!,image2!,image3!]
        let menu = SphereMenu(startPoint: CGPointMake(200, 440), startImage: start!, submenuImages:images, tapToDismiss:true)
        menu.delegate = self
        self.addMenu = menu
        self.timelineView.addSubview(menu)
    }
    
    func sphereDidSelected(index: Int) {
        self.isSettingProfilePhoto = false
        switch index {
            case 0:
                NSLog("camera selected")
                self.takePhoto()
                break
            case 1:
                NSLog("photo selected")
                self.chooseImage()
                break
            case 2:
                NSLog("medical selected")
                self.showMedicalaEntryView()
                break
            default:
                break
        }
        
    }
    
    func showMedicalaEntryView() {
        let nav = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("TimelineEntryFormNavigation") as! UINavigationController
        let detailScene =  nav.topViewController as! TimelineEntryFormViewController
        detailScene.animalObject = self.currentAnimalObject
        detailScene.animalDetailController = self
        detailScene.type = "medical"
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func takePhoto() {
        let cameraViewController : ALCameraViewController = ALCameraViewController(croppingEnabled: true, allowsLibraryAccess: false) { image in
            if image != nil {
                self.modalTransitionStyle = .PartialCurl
                self.dismissViewControllerAnimated(false, completion: { () -> Void in
                })
                self.showEditor(image!, delegate: self, ratios: [["value1": 1, "value2": 1]])
            } else {
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
//        self.modalTransitionStyle = .FlipHorizontal
        cameraViewController.modalTransitionStyle = .CoverVertical
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func chooseImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(self.isSettingProfilePhoto) {
            
            self.dismissViewControllerAnimated(true) { () -> Void in
                let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                self.showEditor(image!, delegate: self, ratios: [["value1": 1, "value2": 1]])
            }
            
        } else {
            let url: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            
            let library = ALAssetsLibrary()
            library.assetForURL(url,
                resultBlock: {
                    (asset: ALAsset!) -> Void in
                    if asset != nil {
                        let date = asset.valueForProperty(ALAssetPropertyDate)
                        self.pickedImageDate = date as? NSDate
                    }
                }, failureBlock: { (error: NSError!) -> Void in
                    print(error)
                }
            )
            
            self.dismissViewControllerAnimated(true) { () -> Void in
                let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                self.showEditor(image!, delegate: self, ratios: [["value1": 1, "value2": 1]])
            }
        }
        

    }

    func imageEditor(editor: CLImageEditor!, didFinishEdittingWithImage image: UIImage!) {
        
        if(self.isSettingProfilePhoto) {
            self.dismissViewControllerAnimated(true) { () -> Void in
                self.setProfilePhoto(image)
                self.isSettingProfilePhoto = false
            }
        } else {
            let nav = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("TimelineEntryFormNavigation") as! UINavigationController
            let detailScene =  nav.topViewController as! TimelineEntryFormViewController
            detailScene.animalObject = self.currentAnimalObject
            detailScene.animalDetailController = self
            detailScene.type = "image"
            detailScene.image = image
            detailScene.pickedImageDate = self.pickedImageDate
            
            self.dismissViewControllerAnimated(false) { () -> Void in
                self.presentViewController(nav, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func profileImagePressed(sender: AnyObject) {
        if(currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsAdmin) {
            self.isSettingProfilePhoto = true
            self.showProfilePhotoActionSheet(sender, delegate: self)
        }
    }
    
    func setProfilePhoto(image: UIImage!) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let fileName:String = (String)(PFUser.currentUser()!.username!) + "-" + (String)(NSDate().description.replace(" ", withString:"_").replace(":", withString:"-").replace("+", withString:"~")) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        self.currentAnimalObject!["profilePhoto"] = imageFile
        
        self.showLoader()
        self.currentAnimalObject!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
            if(success) {
                NSLog("finished saving post")
                self.loadAnimal()
            } else {
                NSLog("error uploading file: \(error?.localizedDescription)")
                self.view.dodo.error((error?.localizedDescription)!)
            }
        }
    }

    
    
    
    func showEditAminalView() {
        self.performSegueWithIdentifier("AnimalDetailToEditAnimal", sender: self)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.goBack()
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func checkOwner() {
        let owner = currentAnimalObject!["owner"] as? PFUser
        let currentUser = PFUser.currentUser()
        
        
        currentUserIsOwner = (currentUser?.objectId == owner?.objectId)
        currentUserIsAdmin = (currentUser?.valueForKey("admin") as! Bool)
        
        if(self.currentAnimalObject != nil) {
            let currentUserShelter = currentUser?.valueForKey("shelter") as? PFObject
            let animalShelter = self.currentAnimalObject!.valueForKey("shelter") as? PFObject
            
            if(currentUserShelter != nil && animalShelter != nil) {
                currentUserIsShelterCaregiver = (currentUserShelter!.objectId == animalShelter!.objectId)
            }
        }
        
    }
    
    func loadAnimal() {
        if let object = currentAnimalObject {
            self.checkOwner()

            //            NSLog("Viewing detail for object: %@\n", object)
            
            if(currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsAdmin) {
                self.createAddMenu()
                
                self.navigationItem.rightBarButtonItem = self.getNavBarItem("setting_white", action: "showEditAminalView", height: 25, width: 25)
            }
                        
            nameLabel.text = object["name"] as? String
            genderLabel.text = object["gender"] as? String
            let birthDate = object["birthDate"] as? NSDate
            let deceasedDate = object["deceasedDate"] as? NSDate
            if(birthDate != nil) {
                ageLabel.text = getAgeString(birthDate!, deceasedDate: deceasedDate)
            } else {
                ageLabel.text = "Age Unknown"
            }
            
            if let coverPhotoFile = object["coverPhoto"] as? PFFile {
                coverPhotoFile.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.coverPhoto.image = image
                    }
                })
            }
            
            if let profilePhotoFile = object["profilePhoto"] as? PFFile {
                
//                self.profileThumb.imageView!.setImageWithURL(NSURL(string: profilePhotoFile.url!)!)
                profilePhotoFile.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.profileThumb.setImage(image?.circle, forState: .Normal)
                    }
                })
            } else if(currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsAdmin) {
                self.profileThumb.imageView!.image = UIImage(named: "avatar_blank_add")
            }
            
            self.breedObject = object.objectForKey("breed") as? PFObject
            if self.breedObject != nil {
                breedButton.setTitle(self.breedObject!.valueForKey("name") as? String, forState: .Normal)
            } else {
                breedButton.hidden = true
            }
            
            self.shelterObject = object.objectForKey("shelter") as? PFObject
            if self.shelterObject != nil && object.valueForKey("adoptable") != nil && object.valueForKey("adoptable") as! Bool {
                shelterButton.setTitle(self.shelterObject!.valueForKey("name") as? String, forState: .Normal)
            } else {
                shelterButton.hidden = true
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "AnimalToBreedDetail") {
            let detailScene = segue.destinationViewController as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        } else if(segue.identifier == "AnimalDetailToEditAnimal"){
            let nav = segue.destinationViewController as! UINavigationController
            let editScene =  nav.topViewController as! AnimalFormViewController
            editScene.detailController = self
            editScene.animalObject = self.currentAnimalObject
        } else if(segue.identifier == "AnimalDetailToLocation") {
            let locationViewController = segue.destinationViewController as! LocationDetailViewController
            locationViewController.currentLocationObject = self.shelterObject
        }  else if(segue.identifier == "AnimalDetailProfileTabsEmbed") {
            
            let timelineViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalTimelineTable") as! AnimalTimelineTableViewController
            timelineViewController.animalObject = self.currentAnimalObject
            timelineViewController.animalDetailController = self
            self.timelineTableController = timelineViewController
            
            let aboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalAbout") as! AnimalAboutViewController
            self.aboutViewController = aboutViewController
            aboutViewController.animalObject = self.currentAnimalObject
            
            let viewControllers = [timelineViewController, aboutViewController]
            
            let options = PagingMenuOptions()
            options.menuHeight = 50
            options.menuPosition = .Top
            options.selectedFont = UIFont(name: "Avenir", size: 18)!
            options.font = UIFont(name: "Avenir", size: 18)!
            options.menuDisplayMode = .SegmentedControl
            options.menuItemMode = .Underline(height: 2.0, color: UIColor.lightGrayColor(), horizontalPadding: 0.0, verticalPadding: 0.0)
            
            let profileTabs = segue.destinationViewController as! PagingMenuController
            profileTabs.delegate = self
            profileTabs.setup(viewControllers: viewControllers, options: options)
            
            if(self.currentAnimalObject?.valueForKey("deceasedDate") != nil) {
                aboutViewController.setInPast()
            }

            
        } else if(segue.identifier == "AnimalDetailTimelineEmbed") {
            let animalTimeline = segue.destinationViewController as! AnimalTimelineTableViewController
            animalTimeline.animalObject = self.currentAnimalObject
            animalTimeline.animalDetailController = self
            self.timelineTableController = animalTimeline
        }
    }

    func willMoveToMenuPage(page: Int) {
        NSLog("moved to \(page)")
        if(currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsAdmin) {
            if(page == 1) {
                self.addMenu!.hidden = true
                for view in self.addMenu!.items! {
                    view.hidden = true
                }
            } else {
                self.addMenu!.hidden = false
                for view in self.addMenu!.items! {
                    view.hidden = false
                }
            }
        }
    }
    
    func didMoveToMenuPage(page: Int) {

    }

    
}