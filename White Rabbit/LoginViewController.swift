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

class LoginViewController: UIViewController, UITextFieldDelegate {
    let permissions = ["public_profile", "email", "user_location", "user_friends"]

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.dodo.topLayoutGuide = topLayoutGuide
        view.dodo.style.bar.hideOnTap = true
        view.dodo.style.bar.hideAfterDelaySeconds = 3
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
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
                self.view.dodo.error((error?.localizedDescription)!)
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
                self.saveUserDataFromFacebook()
            }
            self.hideLoader()
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
