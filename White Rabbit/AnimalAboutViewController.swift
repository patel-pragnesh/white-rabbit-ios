//
//  AnimalAboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import TagListView

class AnimalAboutViewController: UIViewController {

    @IBOutlet weak var traitTags: TagListView!
    @IBOutlet weak var lovesTags: TagListView!
    @IBOutlet weak var hatesTags: TagListView!

    var animalObject : PFObject?
    var traitObjects : [PFObject?] = []
    
    func addTraitTags() {
        let traitsRelation = animalObject!["traits"] as! PFRelation
        let traitsQuery = traitsRelation.query() as PFQuery?
        
        self.traitTags.removeAllTags()
        traitsQuery?.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object.objectForKey("name") as! String
                    self.traitTags.addTag(name)
                    self.traitObjects.append(object)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        traitTags.textFont = UIFont.systemFontOfSize(15)
        
        self.addTraitTags()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
