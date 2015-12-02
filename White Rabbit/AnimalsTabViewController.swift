//
//  AnimalsTabViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import PagingMenuController

class AnimalsTabViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.setUpMenuBarController()
        
        self.loadTabs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpMenuBarController("Cats")
    }
    
    func loadTabs() {
        let myAnimalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsTable") as! AnimalsTableViewController
        myAnimalsViewController.featured = false
        myAnimalsViewController.adoptable = false
        myAnimalsViewController.owner = PFUser.currentUser()
        myAnimalsViewController.title = "Mine"
//        myAnimalsViewController.setCurrentUser()
        
        let featuredAnimalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsTable") as! AnimalsTableViewController
        featuredAnimalsViewController.featured = true
        featuredAnimalsViewController.owner = nil
        featuredAnimalsViewController.adoptable = false
        featuredAnimalsViewController.title = "Featured"

        let adoptableAnimalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsTable") as! AnimalsTableViewController
        adoptableAnimalsViewController.featured = false
        adoptableAnimalsViewController.owner = nil
        adoptableAnimalsViewController.adoptable = true
        adoptableAnimalsViewController.title = "Adoptable"
        
        let viewControllers = [myAnimalsViewController, featuredAnimalsViewController, adoptableAnimalsViewController]
        
        let options = PagingMenuOptions()
        options.menuHeight = 50
        options.menuPosition = .Top
        options.menuDisplayMode = .SegmentedControl
        options.selectedFont = UIFont(name: "Avenir", size: 18)!
        options.font = UIFont(name: "Avenir", size: 18)!
        options.textColor = UIColor.lightGrayColor()
        options.selectedTextColor = UIColor.whiteColor()
        options.backgroundColor = UIColor.darkGrayColor()
        options.selectedBackgroundColor = UIColor.darkGrayColor()
        options.menuItemMode = .Underline(height: 2.0, color: UIColor.lightGrayColor(), horizontalPadding: 0.0, verticalPadding: 0.0)
        
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
//        pagingMenuController.delegate = self
        pagingMenuController.setup(viewControllers: viewControllers, options: options)
    }



}
