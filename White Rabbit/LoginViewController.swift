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
import ParseTwitterUtils
import BWWalkthrough

class LoginViewController: UIViewController, UITextFieldDelegate, BWWalkthroughViewControllerDelegate {
    let permissions = ["public_profile", "email", "user_location", "user_friends"]

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
                
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if !userDefaults.boolForKey("walkthroughPresented") {
            showWalkthrough()
            
            userDefaults.setBool(true, forKey: "walkthroughPresented")
            userDefaults.synchronize()
        }
    }
    
    @IBAction func showWalkthrough(){
        // Get view controllers and build the walkthrough
        let storyboard = self.storyboard!
        let walkthrough = storyboard.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let page_zero = storyboard.instantiateViewControllerWithIdentifier("walk0")
        let page_one = storyboard.instantiateViewControllerWithIdentifier("walk1")
        let page_two = storyboard.instantiateViewControllerWithIdentifier("walk2")
        let page_three = storyboard.instantiateViewControllerWithIdentifier("walk3")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(page_zero)
        
        walkthrough.modalPresentationStyle = .OverCurrentContext
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(walkthrough, animated: false, completion: nil)
        })
    }
    
    func walkthroughPageDidChange(pageNumber: Int) {
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField === usernameField)
        {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if(textField == passwordField) {
            passwordField.resignFirstResponder()
            passwordField.endEditing(true)
            self.loginWithUsername(self)
        }
        return true
    }
    
    @IBAction func loginWithUsername(sender: AnyObject) {
        self.showLoader()
        PFUser.logInWithUsernameInBackground((usernameField.text?.lowercaseString)!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            if user != nil {
                NSLog("finished logging in by username")
                self.goToHome()
            }
            self.hideLoader()
        }
    
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        self.showLoader()
        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.SystemAccount
        
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
//                self.saveUserDataFromFacebook()
            }
            self.hideLoader()
        })
    }
    
    @IBAction func loginWithTwitter(sender: UIButton) {
//        self.showLoader()
        PFTwitterUtils.logInWithBlock { (user: PFUser?, error: NSError?) -> Void in
            if(error != nil) {
                self.showError(error!.localizedDescription)
            }
            
            if let user = user {
                if user.isNew {
                    NSLog("User signed up and logged in with Twitter.")
                    self.saveUserDataFromTwitter(user)
                    self.goToHome()
                } else {
                    NSLog("Existing user logged in with Twitter.")
                    self.goToHome()
                }
            } else {
                NSLog("Uh oh. The user cancelled the Twitter login.")
            }
//            self.hideLoader()
        }
    }
    
    func saveUserDataFromTwitter(user: PFUser) {
        let currentUser = user //PFUser.currentUser()!
        
        if PFTwitterUtils.isLinkedWithUser(currentUser) {
            
            let screenName = PFTwitterUtils.twitter()?.screenName!
            
            let requestString = ("https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
            
            let verify: NSURL = NSURL(string: requestString)!
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: verify)
            PFTwitterUtils.twitter()?.signRequest(request)
            
            var response: NSURLResponse?
            var error: NSError?
            var data: NSData?
            var result: NSDictionary?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            } catch _ {
                NSLog("Error getting data from twitter")
            }
            
            if error == nil {
                let names: String! = result?.objectForKey("name") as! String
                
                let separatedNames: [String] = names.componentsSeparatedByString(" ")
                
                currentUser.setValue(separatedNames.first!, forKey: "firstName")
                currentUser.setValue(separatedNames.last!, forKey: "lastName")
                
//                let urlString = result?.objectForKey("profile_image_url_https") as! String
//                let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                
//                let twitterPhotoUrl = NSURL(string: hiResUrlString)
//                let imageData = NSData(contentsOfURL: twitterPhotoUrl!)
//                let twitterImage: UIImage! = UIImage(data:imageData!)
                
                
                currentUser.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if(success) {
                        NSLog("success saving user info from twitter")
                    } else {
                        NSLog("error saving user info from twitter: \(error)")
                    }
                })
            }
        }
    }
    
    func saveUserDataFromFacebook() {
        
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name,gender"])
        fbRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                let facebookData = result as! NSDictionary //FACEBOOK DATA IN DICTIONARY
                let fbId = (facebookData.objectForKey("id") as? String)
                let first_name = (facebookData.objectForKey("first_name") as? String)
                let last_name = (facebookData.objectForKey("last_name") as? String)
                let email = (facebookData.objectForKey("email") as? String)?.lowercaseString
                
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
    
    func goToHome() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.loadMainController()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
