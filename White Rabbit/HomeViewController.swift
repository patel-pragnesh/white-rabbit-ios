//
//  HomeViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var animalsButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var breedsButton: UIButton!
    
    
    var mainViewController: UIViewController!
    var locationsViewController: UIViewController!
    var breedsViewController: UIViewController!
    
    
    var currentUser: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LocationsTabView")
        self.breedsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BreedsTable")

        
        self.animalsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.locationsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
        self.breedsButton.addTarget(self, action: "showView:", forControlEvents: .TouchUpInside)
    }
    
    func showView(sender: UIButton!) {
        switch sender.currentTitle! {
            case "  Cats":
                self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
                break
            case "  Locations":
                self.slideMenuController()?.changeMainViewController(self.locationsViewController, close: true)
                break
        case "  Breeds":
            self.slideMenuController()?.changeMainViewController(self.breedsViewController, close: true)
            break
            default:
                break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForUser()
    }
    
    func checkForUser() {
        let currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            self.currentUser = currentUser
            self.populateUserInfo()
        } else {
            // Navigate to the LoginViewController
            let lvc = self.storyboard!.instantiateViewControllerWithIdentifier("lvc") as! LoginViewController
            
            self.presentViewController(lvc, animated: true, completion: nil)
            // self.pushViewController(lvc, animated: true)
        }
    }
    
    func populateUserInfo() {
        self.nameLabel.text = (currentUser?.valueForKey("firstName") as? String)! + " " + (currentUser?.valueForKey("lastName") as? String)!

        self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit

        let imageFile = currentUser?.valueForKey("profilePhoto") as! PFFile
        imageFile.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if(error == nil) {
                let image = UIImage(data:imageData!)
                self.profileImageView.image = image
            }
        })
    }

    @IBAction func logout(sender: UIButton) {
        PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in
            if error != nil {
                NSLog("logout fail: \(error)")
            } else {
                NSLog("logout success")
                self.checkForUser()
            }
        }
    }

    
}

