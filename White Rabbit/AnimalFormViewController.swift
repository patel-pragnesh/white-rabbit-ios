//
//  AnimalFormViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/13/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Eureka
import Parse

//class AnimalFormViewController: XLFormViewController {
class AnimalFormViewController : FormViewController {
    
    @IBOutlet var formView: UIView!
    
    let NAME_TAG = "name"
    let BIRTHDATE_TAG = "birthDate"
    let DECEASED_TAG = "deceasedDate"
    let GENDER_TAG = "gender"
    let USERNAME_TAG = "username"

    
    let INSTAGRAM_TAG = "instagramUsername"
    let TWITTER_TAG = "twitterUsername"
    let YOUTUBE_TAG = "youtubeUsername"

    
    var animalObject : PFObject?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func isEditMode() -> Bool {
        return (self.animalObject != nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        
        self.setUpNavigationBar()

        if !self.isEditMode() {
            self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25)
        } else {
            self.navigationItem.title = "Edit Cat"
        }
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveAnimal", height: 20)
    }
    
//    
//    func populateForm() {
//        if self.animalObject != nil {
//            self.form.rowByTag(self.NAME_TAG)?.baseCell.
//        }
//    }
//    
    
    func generateForm() {
        form +++= Section("Info")
            <<< NameRow(NAME_TAG) {
                $0.title = "Name"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.NAME_TAG) as? String
                }
            }
            <<< TwitterRow(USERNAME_TAG) {
                $0.title = "Username"
                $0.value = self.animalObject?.objectForKey(self.USERNAME_TAG) as? String
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "@username"
            }
            <<< DateRow(BIRTHDATE_TAG) {
                $0.title = "Birth Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.BIRTHDATE_TAG) as? NSDate
                }
            }
            <<< DateRow(DECEASED_TAG) {
                $0.title = "Deceased Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.DECEASED_TAG) as? NSDate
                }
            }
            <<< SegmentedRow<String>(GENDER_TAG) {
                $0.title = "Gender"
                $0.options = ["Male", "Female"]
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.GENDER_TAG
                        ) as? String
                }

            }

//        form +++= Section("Photos")
//            <<< ImageRow() {
//                $0.title = "Profile Photo"
//            }
//            <<< ImageRow() {
//                $0.title = "Cover Photo"
//        }

        
        form +++= Section("Details")
            <<< PushRow<String> {
        //            <<< PushSelectorCell<BreedsTableViewCell>("BreedCell") {
                $0.title = "Breed"
                $0.options = ["Bengal", "American Shorthair"]
            }
            <<< PushRow<String> {
                $0.title = "Traits"
                $0.options = ["athletic", "cuddly"]
        }

        form +++= Section("Social")
            <<< TwitterRow(INSTAGRAM_TAG) {
                $0.title = "Instagram"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.INSTAGRAM_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
            }
            <<< TwitterRow(TWITTER_TAG) {
                $0.title = "Twitter"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.TWITTER_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
            }
            <<< TwitterRow(YOUTUBE_TAG) {
                $0.title = "Youtube"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.YOUTUBE_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
            }
    
//        form +++= Section("")
//            <<< ButtonRow("save") { $0.title = "Save" }.onCellSelection { cell, row in print("Cell was selected")
//                    self.saveAnimal()
//            }
//            <<< ButtonRow("cancel") { $0.title = "Cancel" }.onCellSelection { cell, row in                         self.cancel()
//        }

    }
    
    func saveAnimal() {
        NSLog("saving animal")
        var animal = PFObject(className: "Animal")
        if self.isEditMode() {
            animal = self.animalObject!
        }
        
        let nameValue = self.form.rowByTag(self.NAME_TAG)?.baseValue as? String
        let birthDateValue = self.form.rowByTag(self.BIRTHDATE_TAG)?.baseValue as? NSDate
        let deceasedDateValue = self.form.rowByTag(self.DECEASED_TAG)?.baseValue as? NSDate
        let genderValue = self.form.rowByTag(self.GENDER_TAG)?.baseValue as? String
        let usernameValue = self.form.rowByTag(self.USERNAME_TAG)?.baseValue as? String

        let instagramValue = self.form.rowByTag(self.INSTAGRAM_TAG)?.baseValue as? String
        let twitterValue = self.form.rowByTag(self.TWITTER_TAG)?.baseValue as? String
        let youtubeValue = self.form.rowByTag(self.YOUTUBE_TAG)?.baseValue as? String

        
        animal.setObject(nameValue!, forKey: NAME_TAG)
        if birthDateValue != nil {
            animal.setObject(birthDateValue!, forKey: BIRTHDATE_TAG)
        }
        if deceasedDateValue != nil {
            animal.setObject(deceasedDateValue!, forKey: DECEASED_TAG)
        }
        if genderValue != nil {
            animal.setObject(genderValue!, forKey: GENDER_TAG)
        }
        if usernameValue != nil {
            animal.setObject(usernameValue!, forKey: USERNAME_TAG)
        }
        if instagramValue != nil {
            animal.setObject(instagramValue!, forKey: INSTAGRAM_TAG)
        }
        if twitterValue != nil {
            animal.setObject(twitterValue!, forKey: TWITTER_TAG)
        }
        if youtubeValue != nil {
            animal.setObject(youtubeValue!, forKey: YOUTUBE_TAG)
        }

        animal.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("Finished saving")
//                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController!.popViewControllerAnimated(true)
            } else {
                NSLog("%@", error!)
            }
        })
    }
    
    func cancel() {
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
