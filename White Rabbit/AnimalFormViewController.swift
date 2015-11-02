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
                    $0.value = self.animalObject?.objectForKey("name") as? String
                }
            }
            <<< DateRow(BIRTHDATE_TAG) {
                $0.title = "Birth Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey("birthDate") as? NSDate
                }
            }
            <<< DateRow(DECEASED_TAG) {
                $0.title = "Deceased Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey("deceasedDate") as? NSDate
                }
            }
            <<< SegmentedRow<String>(GENDER_TAG) {
                $0.title = "Gender"
                $0.options = ["Male", "Female"]
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey("gender") as? String
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
        
//        form +++= Section("Social")
//            <<< TwitterRow() {
//                $0.title = "Instagram"
//            }.cellSetup { cell, row in
//                cell.textField.placeholder = "@username"
//            }
//            <<< TwitterRow() {
//                $0.title = "Twitter"
//            }.cellSetup { cell, row in
//                cell.textField.placeholder = "@username"
//            }
        
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
        
        animal.setObject(nameValue!, forKey: "name")
        if birthDateValue != nil {
            animal.setObject(birthDateValue!, forKey: "birthDate")
        }
        if deceasedDateValue != nil {
            animal.setObject(deceasedDateValue!, forKey: "deceasedDate")
        }
        if genderValue != nil {
            animal.setObject(genderValue!, forKey: "gender")
        }
        
        animal.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
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
