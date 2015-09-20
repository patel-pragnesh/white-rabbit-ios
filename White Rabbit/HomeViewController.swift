//
//  ViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForUser()
    }

    override func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()
    }
    
    func checkForUser() {
        let currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            self.getUserInfo()
        } else {
            // Navigate to the LoginViewController
            let lvc = self.storyboard!.instantiateViewControllerWithIdentifier("lvc") as! LoginViewController
            
            self.navigationController!.pushViewController(lvc, animated: true)
        }
    }

    
    func getUserInfo() {
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name,gender"])
        fbRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                let facebookData = result as! NSDictionary //FACEBOOK DATA IN DICTIONARY
                NSLog("%@\n", facebookData)
                let userEmail = (facebookData.objectForKey("email") as? String)
                let firstName = (facebookData.objectForKey("first_name") as? String)
                let lastName = (facebookData.objectForKey("last_name") as? String)
                NSLog("User data:\n \(userEmail)\n \(firstName)\n \(lastName)")
            }
        })
    }

}

