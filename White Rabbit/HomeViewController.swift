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
        
        checkForUser(true)
        
        self.animalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsNavigation")
        self.locationsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LocationsMapView")
        self.breedsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BreedsTable")
        self.careViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CareNavigation")
        self.postsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PostsNavigation")
        self.userFormController = self.storyboard?.instantiateViewControllerWithIdentifier("UserNavigation") as! UINavigationController
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
    
    func showView(sender: UIButton!) {
        switch sender.currentTitle! {
            case "  Feed":
                self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
            case "  Cats":
                self.slideMenuController()?.changeMainViewController(self.animalsViewController, close: true)
                break
            case "  Locations":
                self.slideMenuController()?.changeMainViewController(self.locationsViewController, close: true)
                break
            case "  Breeds":
                self.slideMenuController()?.changeMainViewController(self.breedsViewController, close: true)
                break
            case "  Care":
                self.slideMenuController()?.changeMainViewController(self.careViewController, close: true)
                break
            case "Settings":
                self.slideMenuController()?.changeMainViewController(self.userFormController, close: true)
                break
            default:
                break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpMenuBarController("Feed")
        
        checkForUser(true)
    }
    
    func checkForUser(populate: Bool) {
        let currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            self.currentUser = currentUser
            self.checkAdmin()
            if populate {
                self.populateUserInfo()
            }
        } else {
            // Navigate to the LoginViewController
            let lvc = self.storyboard!.instantiateViewControllerWithIdentifier("lvc") as! LoginViewController
            
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
            } else {
                NSLog("logout success")
                self.checkForUser(false)
            }
        }
    }

    
}

