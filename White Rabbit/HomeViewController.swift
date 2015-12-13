//
//  HomeViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ALCameraViewController
import CLImageEditor
import AssetsLibrary

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    
    @IBOutlet weak var animalsButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var breedsButton: UIButton!
    @IBOutlet weak var careButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var feedButton: UIButton!
    
    
    var mainViewController: UIViewController!
    var animalsViewController: UIViewController!
    var locationsViewController: UIViewController!
    var breedsViewController: UIViewController!
    var careViewController: UIViewController!
    var postsViewController: UIViewController!
    var userFormController: UINavigationController!
    
    
    var currentUser: PFUser?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = self.storyboard!
        
        animalsViewController = storyboard.instantiateViewControllerWithIdentifier("AnimalsNavigation")
        locationsViewController = storyboard.instantiateViewControllerWithIdentifier("LocationsMapView")
        breedsViewController = storyboard.instantiateViewControllerWithIdentifier("BreedsTable")
        careViewController = storyboard.instantiateViewControllerWithIdentifier("CareNavigation")
        postsViewController = storyboard.instantiateViewControllerWithIdentifier("PostsNavigation")
        userFormController = storyboard.instantiateViewControllerWithIdentifier("UserNavigation") as! UINavigationController
        let userForm = self.userFormController.topViewController as! UserFormViewController
        userForm.userObject = self.currentUser
        userForm.menuController = self

        self.feedButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.animalsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.locationsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.breedsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.careButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.settingsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.aboutButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setUpMenuBarController("Feed")
        self.checkForUser(true)
        
        super.viewWillAppear(animated)
    }
    
    func showView(sender: UIButton!) {
        switch sender.currentTitle! {
            case "  Feed":
                slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
            case "  Cats":
                slideMenuController()?.changeMainViewController(self.animalsViewController, close: true)
                break
            case "  Locations":
                slideMenuController()?.changeMainViewController(self.locationsViewController, close: true)
                break
            case "  Breeds":
                slideMenuController()?.changeMainViewController(self.breedsViewController, close: true)
                break
            case "  Care":
                slideMenuController()?.changeMainViewController(self.careViewController, close: true)
                break
            case "Settings":
                slideMenuController()?.changeMainViewController(self.userFormController, close: true)
                break
            default:
                break
        }
    }
    
    func checkForUser(populate: Bool) {
        let currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            self.currentUser = currentUser
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.loadMyAnimals()
            
            self.checkAdmin()
            if populate {
                self.populateUserInfo()
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Navigate to the LoginViewController
            let lvc = storyboard.instantiateViewControllerWithIdentifier("lvc") as! LoginViewController
            
            self.presentViewController(lvc, animated: true, completion: nil)
            // self.pushViewController(lvc, animated: true)
        }
    }
    
    func checkAdmin() {
        let isAdmin = self.currentUser!.valueForKey("admin")
        if(isAdmin != nil && isAdmin as! Bool) {
            NSLog("current user is an admin")
        } else {
            NSLog("current user is NOT an admin")
        }
    }
    
    func populateUserInfo() {
        self.nameLabel.text = (currentUser?.valueForKey("firstName") as? String)! + " " + (currentUser?.valueForKey("lastName") as? String)!

        self.profileImageButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit

        let imageFile = currentUser?.valueForKey("profilePhoto") as? PFFile
        if imageFile != nil {
            imageFile!.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.profileImageButton.setImage(image?.circle, forState: .Normal)
                }
            })
        }
    }

    @IBAction func profileImagePressed(sender: AnyObject) {
        self.showProfilePhotoActionSheet(sender, delegate: self)
    }
        
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        self.dismissViewControllerAnimated(true) { () -> Void in
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.showEditor(image!, delegate: self, ratios: [["value1": 1, "value2": 1]])
        }
    }
    
    func imageEditor(editor: CLImageEditor!, didFinishEdittingWithImage image: UIImage!) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.setProfilePhoto(image)
        }
    }
    
    func setProfilePhoto(image: UIImage!) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let fileName:String = (String)(PFUser.currentUser()!.username!) + "-" + (String)(NSDate().description.replace(" ", withString:"_").replace(":", withString:"-").replace("+", withString:"~")) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        self.currentUser!["profilePhoto"] = imageFile
        
        self.showLoader()
        self.currentUser!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
            if(success) {
                NSLog("finished saving post")
                self.populateUserInfo()
            } else {
                NSLog("error uploading file: \(error?.localizedDescription)")
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    
    @IBAction func logout() {
        self.showLoader()
        PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in
            self.hideLoader()
            if error != nil {
                NSLog("logout fail: \(error)")
                self.showError(error!.localizedDescription)
            } else {
                NSLog("logout success")
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.myAnimalsArray = nil
                
                self.checkForUser(false)
            }
        }
    }

    
}

