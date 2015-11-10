//
//  UserSettingsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/6/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Eureka
import Parse

class UserFormViewController : FormViewController {
    
    let FIRST_NAME_TAG = "firstName"
    let LAST_NAME_TAG = "lastName"
    let EMAIL_TAG = "email"
    let PASSWORD_TAG = "password"
    let USERNAME_TAG = "username"
    
    var userObject : PFUser?
    var menuController : HomeViewController?
    
    func isEditMode() -> Bool {
        return (self.userObject != nil)
    }
    
    
    func generateForm() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        form +++= Section("Info")
            <<< NameRow(FIRST_NAME_TAG) {
                $0.title = "First Name"
                if self.isEditMode() {
                    $0.value = self.userObject?.objectForKey(self.FIRST_NAME_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_user")
                }
            <<< NameRow(LAST_NAME_TAG) {
                $0.title = "Last Name"
                if self.isEditMode() {
                    $0.value = self.userObject?.objectForKey(self.LAST_NAME_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_user")
        }
            <<< EmailRow(EMAIL_TAG) {
                $0.title = "Email"
                if self.isEditMode() {
                    $0.value = self.userObject?.objectForKey(self.EMAIL_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_email")
        }
//            <<< NameRow(USERNAME_TAG) {
//                $0.title = "Username"
//                if self.isEditMode() {
//                    $0.value = self.userObject?.objectForKey(self.USERNAME_TAG) as? String
//                }
//                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "form_username")
//            }
            <<< PasswordRow(PASSWORD_TAG) {
                $0.title = "Password"
                if self.isEditMode() {
                    $0.value = self.userObject?.objectForKey(self.PASSWORD_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_password")
        }

        
        
        if(self.isEditMode()) {
            form +++= Section("")
                <<< ButtonRow("remove") { $0.title = "Delete Account" }.onCellSelection { cell, row in print("Removing user")
                    self.removeUser()
                }
                <<< ButtonRow("logout") { $0.title = "Log Out" }.onCellSelection { cell, row in print("Cell was selected")
                    self.menuController!.logout()
//                    self.removeAnimal()
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        
        self.setUpMenuBarController()

        
        if !self.isEditMode() {
            self.navigationItem.title = "New User"
//            self.setUpNavigationBar()
            self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25)

        } else {
            self.navigationItem.title = "Settings"
        }
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveUser", height: 20)
    }

    
    func saveUser() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSLog("saving user")
        var user = PFUser()
        let wasEditMode = self.isEditMode()
        if self.isEditMode() {
            user = self.userObject!
        }
        
        if let firstNameValue = self.form.rowByTag(self.FIRST_NAME_TAG)?.baseValue as? String {
            user.setObject(firstNameValue, forKey: FIRST_NAME_TAG)
        }
        if let lastNameValue = self.form.rowByTag(self.LAST_NAME_TAG)?.baseValue as? String {
            user.setObject(lastNameValue, forKey: LAST_NAME_TAG)
        }
//        let usernameValue = self.form.rowByTag(self.USERNAME_TAG)?.baseValue as? String
//        if usernameValue != nil {
//            user.setObject(usernameValue!, forKey: USERNAME_TAG)
//        }
        let emailValue = self.form.rowByTag(self.EMAIL_TAG)?.baseValue as? String
        if emailValue != nil {
            user.setObject(emailValue!, forKey: EMAIL_TAG)
            user.setObject(emailValue!, forKey: USERNAME_TAG)
        }
        let passwordValue = self.form.rowByTag(self.PASSWORD_TAG)?.baseValue as? String
        if passwordValue != nil {
            user.setObject(passwordValue!, forKey: PASSWORD_TAG)
        }
        
        if(wasEditMode) {
            user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    NSLog("Finished saving user")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    NSLog("%@", error!)
                }
            })
        } else {
            user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    PFUser.logInWithUsernameInBackground(emailValue!.lowercaseString, password: passwordValue!, block: { (user: PFUser?, error: NSError?) -> Void in
                        NSLog("loggedddd in")
                        self.dismissViewControllerAnimated(true, completion: nil)
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.loadMainController()
                    })
                    NSLog("signed up")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    NSLog("%@", error!)
                }
            })
        }
    }
    
    func removeUser() {
        let refreshAlert = UIAlertController(title: "Remove?", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Do it", style: .Default, handler: { (action: UIAlertAction!) in
            self.userObject!.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.displayAlert("Deleted. KTHXBAI.")
                //                refreshAlert.dismissViewControllerAnimated(true, completion: nil)
                self.menuController!.logout()
//                self.dismissViewControllerAnimated(true, completion: nil)
                
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func cancel() {
        NSLog("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
