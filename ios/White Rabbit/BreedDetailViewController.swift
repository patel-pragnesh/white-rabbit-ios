//
//  BreedDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit

class BreedDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var breedImage: UIImageView!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currentBreedObject : PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let object = currentBreedObject {
            self.setUpNavigationBar((object["name"] as? String)!)

            NSLog("Viewing detail for object: %@\n", object)
            
            nameLabel.text = object["name"] as? String
            descriptionLabel.text = object["description"] as? String
            
            let imageFile = object["image"] as? PFFile
            imageFile?.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.breedImage.image = image
                }
            })
        }
    }

}
