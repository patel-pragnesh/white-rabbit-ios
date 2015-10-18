//
//  HomeViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import SideMenu

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var currentUser: PFUser?
    
    var menuItems = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let nav = self.navigationController?.navigationBar
        nav?.hidden = true
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
        nav?.frame.size.height = 50

//        let image = UIImage(named: "bg copy copy")
//        nav?.setBackgroundImage(image, forBarMetrics: .Default)

        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        
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
        self.emailLabel.text = currentUser?.valueForKey("email") as? String

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

