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
            <<< NameRow(EMAIL_TAG) {
                $0.title = "Email"
                if self.isEditMode() {
                    $0.value = self.userObject?.objectForKey(self.EMAIL_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_email")
        }
        
        if(self.isEditMode()) {
            form +++= Section("")
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
        } else {
            self.navigationItem.title = "Settings"
        }
//        self.setUpNavigationBar()
//        self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25)
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveUser", height: 20)
    }

    
    func saveUser() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSLog("saving user")
        var user = PFUser()
//        let wasEditMode = self.isEditMode()
        if self.isEditMode() {
            user = self.userObject!
        }
        
        if let firstNameValue = self.form.rowByTag(self.FIRST_NAME_TAG)?.baseValue as? String {
            user.setObject(firstNameValue, forKey: FIRST_NAME_TAG)
        }
        
        user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("Finished saving")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                NSLog("%@", error!)
            }
        })
    }
    
    func cancel() {
        NSLog("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
