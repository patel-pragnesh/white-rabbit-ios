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
    let PROFILE_PHOTO_TAG = "profilePhoto"
    let COVER_PHOTO_TAG = "coverPhoto"
    
    let BIRTHDATE_TAG = "birthDate"
    let DECEASED_TAG = "deceasedDate"
    let GENDER_TAG = "gender"
    let USERNAME_TAG = "username"

    let TRAITS_TAG = "traits"
    let BREED_TAG = "breed"
    let SHELTER_TAG = "shelter"
    
    let ADOPTABLE_TAG = "adoptable"
    let FEATURED_TAG = "featured"
    
    let INSTAGRAM_TAG = "instagramUsername"
    let TWITTER_TAG = "twitterUsername"
    let YOUTUBE_TAG = "youtubeUsername"
    let FACEBOOK_TAG = "facebookPageId"

    var detailController : AnimalDetailViewController?
    var animalTableController : AnimalsTableViewController?
    var animalObject : PFObject?
    var selectedTraitStrings : Set<String>?
    var userObject : PFUser?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func isEditMode() -> Bool {
        return (self.animalObject != nil)
    }
    
    func loadTraits() {
        NSLog("loading traits")
        if let animal = self.animalObject {
            NSLog("animal set - getting traits")
            let relation = animal.objectForKey("traits") as! PFRelation
            let traitsQuery = relation.query() as PFQuery?
            
            traitsQuery?.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    NSLog("found traits \(objects)")
                    var value = Set<String>()
                    for object in objects! {
                        value.insert(object.valueForKey("name") as! String)
                    }
                    self.selectedTraitStrings = value
                    self.form.rowByTag(self.TRAITS_TAG)?.baseValue = value
                    self.form.rowByTag(self.TRAITS_TAG)?.updateCell()
                }
            })
        }
    }
    
    func saveTraits(traitObjects: [PFObject?]) {
        let relation = self.animalObject!.relationForKey("traits")
        
        // clear out all previous traits
        // TODO - figure out a more efficient way to do this
        let traitsQuery = PFQuery(className: "Trait")
        let allTraits = try! traitsQuery.findObjects()
        for traitObject in allTraits {
            relation.removeObject(traitObject)
        }
        
        for traitObject in traitObjects {
            print("adding: \(traitObject)!")
            relation.addObject(traitObject!)
        }
        
        self.animalObject!.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            NSLog("traits saved!!!!")
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTraits()
        
        self.generateForm()
        
        self.setUpNavigationBar()

        if !self.isEditMode() {
            self.navigationItem.title = "New Cat"
        } else {
            self.navigationItem.title = "Cat Settings"
        }
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "cancel", height: 25)
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        form +++= Section("Info")
            <<< NameRow(NAME_TAG) {
                $0.title = "Cat's Name"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.NAME_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_user")
            }
            <<< TwitterRow(USERNAME_TAG) {
                $0.title = "Username"
                $0.value = self.animalObject?.objectForKey(self.USERNAME_TAG) as? String
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "@username"
                    cell.imageView?.image = UIImage(named: "form_username")
            }
            <<< DateRow(BIRTHDATE_TAG) {
                $0.title = "Birth Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.BIRTHDATE_TAG) as? NSDate
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_birthdate")
            }
            <<< DateRow(DECEASED_TAG) {
                $0.title = "Deceased Date"
                $0.hidden = .Function([self.ADOPTABLE_TAG], { form -> Bool in
                    let row: RowOf<NSDate>! = form.rowByTag(self.BIRTHDATE_TAG)
                    return row.value ?? false == true
                })
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.DECEASED_TAG) as? NSDate
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_date")
            }
            <<< SegmentedRow<String>(GENDER_TAG) {
                $0.title = "Gender"
                $0.options = ["Male", "Female"]
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.GENDER_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_gender")
            }
//            <<< SegmentedRow<String>(GENDER_TAG) {
//                $0.title = "Gender"
//                $0.options = ["Male", "Female"]
//                if self.isEditMode() {
//                    $0.value = self.animalObject?.objectForKey(self.GENDER_TAG) as? String
//                }
//            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_birthdate")
////                cell.textLabel!.frame = CGRectMake(cell.textLabel!.frame.origin.x + 100, cell.textLabel!.frame.origin.y, cell.textLabel!.frame.size.width, cell.textLabel!.frame.size.height);
//            }

        form +++= Section("Photos")
            <<< ImageRow(PROFILE_PHOTO_TAG) {
                $0.title = "Profile Photo"
            }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_profile_photo")
            }
            <<< ImageRow(COVER_PHOTO_TAG) {
                $0.title = "Cover Photo"
            }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_cover_photo")
        }

        
        form +++= Section("Details")
            <<< PushRow<String>(BREED_TAG) {
        //            <<< PushSelectorCell<BreedsTableViewCell>("BreedCell") {
                $0.title = "Breed"
                $0.options = appDelegate.breedsArray!
                if self.isEditMode() {
                    let breedObject = self.animalObject?.objectForKey(self.BREED_TAG) as? PFObject
                    if(breedObject != nil) {
                        $0.value = breedObject!.objectForKey("name") as? String
                    }
                }

            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_breed")
            }
            <<< MultipleSelectorRow<String>(TRAITS_TAG) {
                $0.title = "Traits"
                $0.options = appDelegate.traitsArray!
                NSLog("creating traits row")
                if self.isEditMode() {
                    NSLog("selected traits are: \(self.selectedTraitStrings)")

                    $0.value = self.selectedTraitStrings
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_traits")
            }

        form +++= Section("Social")
            <<< TwitterRow(INSTAGRAM_TAG) {
                $0.title = "Instagram"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.INSTAGRAM_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
                cell.imageView?.image = UIImage(named: "form_instagram")
            }
            <<< TwitterRow(TWITTER_TAG) {
                $0.title = "Twitter"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.TWITTER_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
                cell.imageView?.image = UIImage(named: "form_twitter")
            }
            <<< TwitterRow(YOUTUBE_TAG) {
                $0.title = "Youtube"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.YOUTUBE_TAG) as? String
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "@username"
                cell.imageView?.image = UIImage(named: "form_youtube")
            }
            <<< TwitterRow(FACEBOOK_TAG) {
                $0.title = "Facebook"
                if self.isEditMode() {
                    $0.value = self.animalObject?.objectForKey(self.FACEBOOK_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "page_id"
                    cell.imageView?.image = UIImage(named: "form_facebook")
        }

        
            form +++= Section("Flags")
                <<< SwitchRow(ADOPTABLE_TAG) {
                    $0.title = "Adoptable"
                    $0.value = false
                    if self.isEditMode() {
                        $0.value = self.animalObject?.objectForKey(self.ADOPTABLE_TAG) as? Bool
                    }
                }
                
                <<< PushRow<String>(SHELTER_TAG) {
                    $0.title = "Shelter"
                    $0.options = appDelegate.sheltersArray!
                    $0.hidden = .Function([self.ADOPTABLE_TAG], { form -> Bool in
                        let row: RowOf<Bool>! = form.rowByTag(self.ADOPTABLE_TAG)
                        return row.value ?? false == false
                    })
                    if self.isEditMode() {
                        let shelterObject = self.animalObject?.objectForKey(self.SHELTER_TAG) as? PFObject
                        if(shelterObject != nil) {
                            $0.value = shelterObject!.objectForKey("name") as? String
                        }
                    }
                }
        
                <<< SwitchRow(FEATURED_TAG) {
                    $0.title = "Featured"
                    $0.value = false
                    if self.isEditMode() {
                        $0.value = self.animalObject?.objectForKey(self.FEATURED_TAG) as? Bool
                    }
        }
        
        if(self.isEditMode()) {
            form +++= Section("")
                <<< ButtonRow("remove") { $0.title = "Remove" }.onCellSelection { cell, row in print("Cell was selected")
                    self.removeAnimal()
            }
        }
//            <<< ButtonRow("save") { $0.title = "Save" }.onCellSelection { cell, row in print("Cell was selected")
//                    self.saveAnimal()
//            }
//            <<< ButtonRow("cancel") { $0.title = "Cancel" }.onCellSelection { cell, row in                         self.cancel()
//        }

    }

    func removeAnimal() {
        let refreshAlert = UIAlertController(title: "Remove?", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Do it", style: .Default, handler: { (action: UIAlertAction!) in
            self.animalObject!.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
//                self.displayAlert("Deleted. KTHXBAI.")
//                refreshAlert.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    if self.detailController != nil {
                        self.detailController!.closeScreen(self)
                    }
                })
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
        
    
    func saveAnimal() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        NSLog("saving animal")
        var animal = PFObject(className: "Animal")
        let wasEditMode = self.isEditMode()
        if self.isEditMode() {
            animal = self.animalObject!
        }
        
        if let nameValue = self.form.rowByTag(self.NAME_TAG)?.baseValue as? String {
            animal.setObject(nameValue, forKey: NAME_TAG)
        }
//        if let profilePhotoValue = self.form.rowByTag(self.PROFILE_PHOTO_TAG)?.baseValue as? NSFile {
//            animal.setObject(birthDateValue, forKey: BIRTHDATE_TAG)
//        }
        
        if let breedValue = self.form.rowByTag(self.BREED_TAG)?.baseValue as? String {
            let breed = appDelegate.breedByName![breedValue]
            NSLog("XBreed: \(breed?.valueForKey("objectId"))")
            animal.setObject(breed!, forKey: BREED_TAG)
        }
        
        if let traitsValue = self.form.rowByTag(self.TRAITS_TAG)?.baseValue as? Set<String> {
            var traitObjects = [PFObject?]()
            for trait in traitsValue{
                let trait = appDelegate.traitByName![trait]
                traitObjects.append(trait)
            }
            self.saveTraits(traitObjects)
//            animal.setObject(breed!, forKey: BREED_TAG)
        }

        
        
        if let birthDateValue = self.form.rowByTag(self.BIRTHDATE_TAG)?.baseValue as? NSDate {
            animal.setObject(birthDateValue, forKey: BIRTHDATE_TAG)
        }
        if let deceasedDateValue = self.form.rowByTag(self.DECEASED_TAG)?.baseValue as? NSDate {
            animal.setObject(deceasedDateValue, forKey: DECEASED_TAG)
        }
        if let genderValue = self.form.rowByTag(self.GENDER_TAG)?.baseValue as? String {
            animal.setObject(genderValue, forKey: GENDER_TAG)
        }
        if let usernameValue = self.form.rowByTag(self.USERNAME_TAG)?.baseValue as? String {
            animal.setObject(usernameValue, forKey: USERNAME_TAG)
        }
        if let facebookValue = self.form.rowByTag(self.FACEBOOK_TAG)?.baseValue as? String {
            animal.setObject(facebookValue, forKey: FACEBOOK_TAG)
        }
        
        if let instagramValue = self.form.rowByTag(self.INSTAGRAM_TAG)?.baseValue as? String {
            animal.setObject(instagramValue, forKey: INSTAGRAM_TAG)
        }
        
        if let twitterValue = self.form.rowByTag(self.TWITTER_TAG)?.baseValue as? String {
            animal.setObject(twitterValue, forKey: TWITTER_TAG)
        }
        
        if let youtubeValue = self.form.rowByTag(self.YOUTUBE_TAG)?.baseValue as? String {
            animal.setObject(youtubeValue, forKey: YOUTUBE_TAG)
        }

        if let featuredValue = self.form.rowByTag(self.FEATURED_TAG)?.baseValue as? Bool {
            animal.setObject(featuredValue, forKey: FEATURED_TAG)
        }
        if let adoptableValue = self.form.rowByTag(self.ADOPTABLE_TAG)?.baseValue as? Bool {
            animal.setObject(adoptableValue, forKey: ADOPTABLE_TAG)
        }
        
        if let shelterValue = self.form.rowByTag(self.SHELTER_TAG)?.baseValue as? String {
            let shelter = appDelegate.shelterByName![shelterValue]
            animal.setObject(shelter!, forKey: SHELTER_TAG)
        }
        
        if !self.isEditMode() {
            animal.setObject(self.userObject!, forKey: "owner")
        }
        
        animal.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("Finished saving")
//                if(wasEditMode) {
//                    self.navigationController!.popViewControllerAnimated(true)
//                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    if self.detailController != nil {
                        self.detailController!.loadAnimal()
                    } else if self.animalTableController != nil {
                        self.animalTableController!.loadObjects()
                    }
//                }
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
