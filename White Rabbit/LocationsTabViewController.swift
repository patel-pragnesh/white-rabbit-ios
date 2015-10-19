//
//  LocationsTabViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class LocationsTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.barTintColor = UIColor.darkGrayColor()
        self.tabBar.backgroundColor = UIColor.darkGrayColor()
        self.tabBar.tintColor = UIColor.whiteColor()
        
        self.tabBar.frame.size.height = 150
        
//        let items = ["Shelters", "Vets", "Pet Supplies", "Grooming"]
//        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items)
//        menuView.cellTextLabelColor = UIColor.whiteColor()
//        menuView.cellBackgroundColor = UIColor.darkGrayColor()
//        self.tabBarController?.navigationItem.titleView = menuView
//        self.navigationItem.titleView = menuView
        
//        let nav = self.navigationController?.navigationBar
//        nav?.barStyle = UIBarStyle.BlackTranslucent
//        nav?.tintColor = UIColor.whiteColor()
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
//        let items = ["Shelters", "Vets", "Pet Supplies", "Grooming"]
//        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items)
//        menuView.tintColor = UIColor.whiteColor()
//        menuView.cellBackgroundColor = UIColor.darkGrayColor()
//        menuView.menuTitleColor = UIColor.whiteColor()
//        menuView.cellTextLabelColor = UIColor.whiteColor()
//        menuView.cellSelectionColor = UIColor.whiteColor()
//        menuView.tintColor = UIColor.whiteColor()
//        menuView.maskBackgroundColor = UIColor.whiteColor()
//
//        
//        self.navigationItem.titleView = menuView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
