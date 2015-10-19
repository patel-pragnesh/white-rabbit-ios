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
    let GENDER_TAG = "gender"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        
        self.setUpNavigationBar()

        self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25)
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveAnimal", height: 20)
    }
    
    func generateForm() {
        
        form +++= Section("Info")
            <<< NameRow(NAME_TAG) {
                $0.title = "Name"
            }
            <<< DateRow(BIRTHDATE_TAG) {
                $0.title = "Birth Date"
            }
            <<< SegmentedRow<String>(GENDER_TAG) {
                $0.title = "Gender"
                $0.options = ["Male", "Female"]
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
        let animal = PFObject(className: "Animal")
        
        let nameValue = self.form.rowByTag(self.NAME_TAG)?.baseValue as? String
        let birthDateValue = self.form.rowByTag(self.BIRTHDATE_TAG)?.baseValue as? NSDate
        let genderValue = self.form.rowByTag(self.GENDER_TAG)?.baseValue as? String
        
        animal.setObject(nameValue!, forKey: "name")
        if birthDateValue != nil {
            animal.setObject(birthDateValue!, forKey: "birthDate")
        }
        if genderValue != nil {
            animal.setObject(genderValue!, forKey: "gender")
        }
        
        animal.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                // self.displayAlert("saved")
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
