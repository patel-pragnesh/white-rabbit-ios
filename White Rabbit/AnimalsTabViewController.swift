//
//  AnimalsTabViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import PagingMenuController

class AnimalsTabViewController: UIViewController, PagingMenuControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpMenuBarController("Cats")
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("add_white", action: "showAddAminalView", height: 25, width: 25)
    }
    
    func showAddAminalView() {
        self.performSegueWithIdentifier("AnimalTabToAddAnimal", sender: self)
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
        
        var viewControllers = [myAnimalsViewController, featuredAnimalsViewController]

//        let shelter = PFUser.currentUser()?.valueForKey("shelter") as? PFObject
//        if shelter != nil {
//            do {
//                try shelter!.fetch()
//            } catch _ {
//                NSLog("couldnt fetch")
//            }
//
//            let shelterAnimalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsTable") as! AnimalsTableViewController
//            shelterAnimalsViewController.featured = false
//            shelterAnimalsViewController.owner = nil
//            shelterAnimalsViewController.adoptable = false
//            shelterAnimalsViewController.shelter = shelter
//            let shelterName = shelter?.valueForKey("name") as? String
//            if(shelterName != nil) {
//                shelterAnimalsViewController.title = shelterName
//            } else {
//                shelterAnimalsViewController.title = "Adoptable"
//            }
//
//            viewControllers.append(shelterAnimalsViewController)
//        } else {
            let adoptableAnimalsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalsTable") as! AnimalsTableViewController
            adoptableAnimalsViewController.featured = false
            adoptableAnimalsViewController.owner = nil
            adoptableAnimalsViewController.adoptable = true
            adoptableAnimalsViewController.title = "Adoptable"
            
            viewControllers.append(adoptableAnimalsViewController)
//        }
        
        
        let options = PagingMenuOptions()
        options.menuHeight = 50
        options.menuPosition = .Top
//        options.menuDisplayMode = .SegmentedControl
        options.menuDisplayMode = .Infinite(widthMode: PagingMenuOptions.MenuItemWidthMode.Flexible)
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

    func willMoveToMenuPage(page: Int) {
        
    }
    
    func didMoveToMenuPage(page: Int) {
    }

}
