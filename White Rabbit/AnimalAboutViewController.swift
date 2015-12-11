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

    @IBOutlet weak var breedTitle: UILabel!
    @IBOutlet weak var breedLogo: UIImageView!
    @IBOutlet weak var afterBreedConstraint: NSLayoutConstraint!
    @IBOutlet weak var coatTitle: UILabel!
    @IBOutlet weak var coatLogo: UIImageView!
    @IBOutlet weak var afterCoatConstraint: NSLayoutConstraint!
    @IBOutlet weak var traitTitle: UILabel!
    @IBOutlet weak var traitLogo: UIImageView!
    @IBOutlet weak var lovesTitle: UILabel!
    @IBOutlet weak var lovesLogo: UIImageView!
    @IBOutlet weak var hatesTitle: UILabel!
    @IBOutlet weak var hatesLogo: UIImageView!
    
    @IBOutlet weak var coatLabel: UILabel!

    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var animalObject : PFObject?
    var traitObjects : [PFObject?] = []
    
    func setInPast() {
        self.lovesTitle.text = "Loved"
        self.hatesTitle.text = "Hated"
    }
    
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
    
    func addLovesTags() {
        let loves = animalObject!["loves"] as? [String]

        self.lovesTags.removeAllTags()

        if loves != nil {
            for love in loves! {
                self.lovesTags.addTag(love)
            }
        }
    }
    
    func addHatesTags() {
        let hates = animalObject!["hates"] as? [String]
        
        self.hatesTags.removeAllTags()
        if hates != nil {
            for hate in hates! {
                self.hatesTags.addTag(hate)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traitTags.textFont = UIFont.systemFontOfSize(15)
        lovesTags.textFont = UIFont.systemFontOfSize(15)
        hatesTags.textFont = UIFont.systemFontOfSize(15)
        
        self.loadAnimal()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadAnimal()
    }
    
    func loadAnimal() {
        if(self.animalObject != nil) {
            if let breed = animalObject!["breed"] as? PFObject {
                let name = breed.valueForKey("name") as! String
                self.breedLabel.text = name
            } else {
                //            breedLabel.hidden = true
                //            breedLogo.hidden = true
                //            breedTitle.hidden = true
                //            afterBreedConstraint.constant = -20.0
            }
            
            if let coat = animalObject!["coat"] as? PFObject {
                let name = coat.valueForKey("name") as! String
                self.coatLabel.text = name
            } else {
                //            coatLabel.hidden = true
                //            coatLogo.hidden = true
                //            coatTitle.hidden = true
                //            afterCoatConstraint.constant = -20.0
            }
            
            self.addTraitTags()
            self.addLovesTags()
            self.addHatesTags()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
