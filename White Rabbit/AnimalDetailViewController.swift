//
//  CatDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import XLForm
import TagListView

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var traitTags: TagListView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!

    
    var currentAnimalObject : PFObject?
    var breedObject : PFObject?
    var traitObjects : [PFObject]? = []
    
//    @IBAction func viewBreedDetail(sender: UIButton) {
//        NSLog("viewing breed detail")
//        self.performSegueWithIdentifier("AnimalToBreedDetail", sender: self)
//    }
    
    func saveTraits(traitObjects: [PFObject?]) {
        let relation = self.currentAnimalObject?.relationForKey("traits")
        
        // clear out all previous traits
        // TODO - figure out a more efficient way to do this
        let traitsQuery = PFQuery(className: "Trait")
        let allTraits = try! traitsQuery.findObjects()
        for traitObject in allTraits {
            relation?.removeObject(traitObject)
        }
            
        for traitObject in traitObjects {
            print("adding: \(traitObject)!")
            relation?.addObject(traitObject!)
        }
        
        self.currentAnimalObject?.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            self.addTraitTags()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traitTags.textFont = UIFont.systemFontOfSize(15)

        
        if let object = currentAnimalObject {
//            NSLog("Viewing detail for object: %@\n", object)
            
            nameLabel.text = object["name"] as? String
            genderLabel.text = object["gender"] as? String
            let birthDate = object["birthDate"] as? NSDate
            ageLabel.text = getAgeString(birthDate!)
            
            self.addTraitTags()
            
            self.breedObject = object.objectForKey("breed") as? PFObject
            breedButton.setTitle(self.breedObject!.valueForKey("name") as? String, forState: .Normal)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func getAgeString(birthDate: NSDate) -> String {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let ageComponents = calendar.components(.Year,
            fromDate: birthDate,
            toDate: now,
            options: [])
        
        let ageString = String(ageComponents.year) + " years old"
        // + String(ageComponents.month) + " months"
        
        return ageString
    }
    
    func addTraitTags() {
        if let animalObject = currentAnimalObject {
            let traitsRelation = animalObject["traits"] as! PFRelation
            let traitsQuery = traitsRelation.query() as PFQuery?

            self.traitTags.removeAllTags()
            traitsQuery?.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        let name = object.objectForKey("name") as! String
                        self.traitTags.addTag(name)
                        self.traitObjects?.append(object)
                    }
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        
        if(segue.identifier == "AnimalToBreedDetail") {
            let detailScene = segue.destinationViewController as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        } else if(segue.identifier == "AnimalToTraitSelector") {
            let traitSelector = segue.destinationViewController as! TraitSelectorTableViewController
            NSLog("trait objects before: \(self.traitObjects)")
            traitSelector.selectedTraitObjects = self.traitObjects
            traitSelector.animalViewController = self
        }
    }

}