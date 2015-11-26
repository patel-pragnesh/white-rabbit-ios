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
    let SHELTER_TAG = "shelter"
    let ADMIN_TAG = "admin"
    
    var userObject : PFUser?
    var menuController : HomeViewController?
    
    func isEditMode() -> Bool {
        return (self.userObject != nil)
    }
    
    
    func generateForm() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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

            <<< PushRow<String>(SHELTER_TAG) {
                $0.title = "Shelter"
                $0.options = appDelegate.sheltersArray!
                $0.hidden = .Function(["admin"], { form -> Bool in
                    return self.isEditMode() && !(self.userObject?.valueForKey(self.ADMIN_TAG) as! Bool)
                })
                if self.isEditMode() {
                    let shelterObject = self.userObject?.objectForKey(self.SHELTER_TAG) as? PFObject
                    if(shelterObject != nil) {
                        $0.value = shelterObject!.objectForKey("name") as? String
                    }
                }
        }
        
        if(self.isEditMode()) {
            form +++= Section("")
                <<< ButtonRow("remove") {
                        $0.title = "Delete Account"
                        $0.hidden = .Function(["admin"], { form -> Bool in
                            return !(self.userObject?.valueForKey(self.ADMIN_TAG) as! Bool)
                        })
                    }.onCellSelection { cell, row in print("Removing user")
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
        
        view.dodo.topLayoutGuide = topLayoutGuide
        view.dodo.style.bar.hideOnTap = true
        view.dodo.style.bar.hideAfterDelaySeconds = 3
        
        self.generateForm()
        
        self.setUpMenuBarController()
        
        if !self.isEditMode() {
            self.navigationItem.title = "New User"
//            self.setUpNavigationBar()
            self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25, width: 25)

        } else {
            self.navigationItem.title = "Settings"
        }
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveUser", height: 20, width: 25)
    }

    
    func saveUser() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        
        if let shelterValue = self.form.rowByTag(self.SHELTER_TAG)?.baseValue as? String {
            let shelter = appDelegate.shelterByName![shelterValue]
            user.setObject(shelter!, forKey: SHELTER_TAG)
        }
        
        if(wasEditMode) {
            self.showLoader()
            user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    NSLog("Finished saving user")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.view.dodo.error(error!.localizedDescription)
                    NSLog("%@", error!)
                }
                self.hideLoader()
            })
        } else {
            self.showLoader()
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
                    self.displayAlert(error!.localizedDescription)
//                    self.view.dodo.error(error!.localizedDescription)
                    NSLog("%@", error!)
                }
                self.hideLoader()
            })
        }
    }
    
    func removeUser() {
        let refreshAlert = UIAlertController(title: "Remove?", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Do it", style: .Default, handler: { (action: UIAlertAction!) in
            self.showLoader()
            self.userObject!.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.hideLoader()
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
