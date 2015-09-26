//
//  CatDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedButton: UIButton!
    
    var currentAnimalObject : PFObject?
    var breedObject : PFObject?
    
//    @IBAction func viewBreedDetail(sender: UIButton) {
//        NSLog("viewing breed detail")
//        self.performSegueWithIdentifier("AnimalToBreedDetail", sender: self)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let object = currentAnimalObject {
            NSLog("Viewing detail for object: %@\n", object)
            
            nameLabel.text = object["name"] as? String
            
            self.breedObject = object.objectForKey("breed") as? PFObject
            
            NSLog("breed: %@\n", self.breedObject!)
            breedButton.setTitle(self.breedObject!.valueForKey("name") as? String, forState: .Normal)
        }
        
        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        let detailScene = segue.destinationViewController as! BreedDetailViewController

        detailScene.currentBreedObject = self.breedObject
    }

}