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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var breedImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currentBreedObject : PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize.height = 1500

        // NSLog("Trying to load detail for object: %@\n", self.currentBreedObject!)
        
        if let object = currentBreedObject {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
