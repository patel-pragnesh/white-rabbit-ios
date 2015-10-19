//
//  LoginViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    let permissions = ["public_profile", "email", "user_location", "user_friends"]
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(self.permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
            } else if user!.isNew {
                NSLog("User signed up and logged in through Facebook! \(user!.username)")
                self.goToHome()
                self.saveUserDataFromFacebook()
            } else {
                NSLog("User logged in through Facebook! \(user!.username)")
                self.goToHome()
                self.saveUserDataFromFacebook()
            }
        })
    }
    
    func saveUserDataFromFacebook() {
        
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name,gender"])
        fbRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                let facebookData = result as! NSDictionary //FACEBOOK DATA IN DICTIONARY
                NSLog("%@\n", facebookData)
                let fbId = (facebookData.objectForKey("id") as? String)
                let first_name = (facebookData.objectForKey("first_name") as? String)
                let last_name = (facebookData.objectForKey("last_name") as? String)
                let email = (facebookData.objectForKey("email") as? String)
                
                let user = PFUser.currentUser()
                user?.setValue(email, forKey: "email")
                user?.setValue(first_name, forKey: "firstName")
                user?.setValue(last_name, forKey: "lastName")
                
                if let url = NSURL(string: "https://graph.facebook.com/\(fbId!)/picture?type=large") {
                    if let data = NSData(contentsOfURL: url){

                        let fileName:String = fbId! + ".jpg"
                        let imageFile:PFFile = PFFile(name: fileName, data: data)!
                        
                        user?.setValue(imageFile, forKey: "profilePhoto")
                    }
                }
                
                NSLog("user to save: %@\n", user!)
                user?.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if(success) {
                        NSLog("success saving user info from facebook")
                    } else {
                        NSLog("error saving user info from facebook: \(error)")
                    }
                })
            }
        })
        
    }
    
    @IBAction func registerByEmail(sender: UIButton) {
        let user = PFUser()

//        user.username = email.text
//        user.email = email.text?.lowercaseString
//        user.password = password.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                // Success signing up
                
                self.goToHome()
                
            } else {
                // Error signing up
                let errorString = error?.userInfo["error"] as! String
                
                let errorAlert = UIAlertController(title: "Error", message: errorString.capitalizedString, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func goToHome() {
//        let hvc = self.storyboard!.instantiateViewControllerWithIdentifier("home") as! HomeViewController
//        
//        self.presentViewController(hvc, animated: true, completion: nil)
        
        self.storyboard!.instantiateInitialViewController()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
