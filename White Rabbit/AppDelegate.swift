//
//  AppDelegate.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Parse
import ParseCrashReporting
import ParseFacebookUtilsV4
import ParseTwitterUtils
import SlideMenuControllerSwift
import ContentfulDeliveryAPI
import BWWalkthrough

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: CDAClient?

    var myAnimalsArray: [PFObject]?
    
    var traitsArray: [String]?
    var traitByName: [String: PFObject]?
    var breedsArray: [String]?
    var breedByName: [String: PFObject]?
    var sheltersArray: [String]?
    var shelterByName: [String: PFObject]?
    var vetsArray: [String]?
    var vetByName: [String: PFObject]?
    
    var lovesArray: [String]?
    var loveByName: [String: PFObject]?
    var hatesArray: [String]?
    var hateByName: [String: PFObject]?

    var coatsArray: [String]?
    var coatByName: [String: PFObject]?
    var coatImagesByName: [String: UIImage]?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Parse.enableLocalDatastore()
        ParseCrashReporting.enable()
        PFUser.enableRevocableSessionInBackground()

        // Initialize Parse.
        Parse.setApplicationId("IWr9xzTirLbjXH80mbTCtT9lWB73ggQe3PhA6nPg", clientKey: "Yxdst3hz76abMoAwG7FLh0NwDmPvYHFDUPao9WJJ")


        // Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFTwitterUtils.initializeWithConsumerKey("C16iyeaMoc91iPOQnBTnQkXgm", consumerSecret: "gvedI21p7UaJxEJKxyTttbkUydE37cnq3RBSUFB86erwjHAkt1")

        
        self.client = CDAClient(spaceKey:"8mu31kgi73w0", accessToken:"3bd31581398aa28d0b9c05aa86573763aa4dfd4119eb020625cd0989fee99836")
        
        UILabel.appearance().substituteFontName = "Avenir"
        
        loadTraits()
        loadBreeds()
        loadShelters()
        loadVets()
        loadLoves()
        loadHates()
        loadCoats()
        loadMainController()

        NSLog("Finished loading background data")
        
        return true
    }
    
    func loadMainController() {
        //        var storyboard = self.window?.rootViewController?.storyboard
        //        if(storyboard == nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        }
        
        let homeController = storyboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
        homeController.checkForUser(false)
        //        let mainController = storyboard?.instantiateViewControllerWithIdentifier("AnimalsNavigation")
        let mainController = storyboard.instantiateViewControllerWithIdentifier("PostsNavigation")
        homeController.mainViewController = mainController
        
        let slideMenuController = SlideMenuController(mainViewController: mainController, leftMenuViewController: homeController)
        
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }

    
    
    func loadMyAnimals() {
        let animalQuery = PFQuery(className:"Animal")
        animalQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        animalQuery.includeKey("breed")
        animalQuery.includeKey("coat")
        animalQuery.includeKey("shelter")
        animalQuery.includeKey("owner")
        
        self.myAnimalsArray = [PFObject]()
        
        animalQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.myAnimalsArray = objects
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }


    func loadCoats() {
        let coatQuery = PFQuery(className:"Coat")
        self.coatsArray = [String]()
        self.coatByName = [String:PFObject]()
        self.coatImagesByName = [String:UIImage]()
        
        coatQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["name"] as! String
                    self.coatsArray?.append(name)
                    self.coatByName![name] = object
                    
                    if let imageFile = object["image"] as? PFFile {
                        imageFile.getDataInBackgroundWithBlock({
                            (imageData: NSData?, error: NSError?) -> Void in
                            if(error == nil) {
                                self.coatImagesByName![name] = UIImage(data:imageData!)
                            }
                        })
                    }
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    
    func loadTraits() {
        let traitQuery = PFQuery(className:"Trait")
        self.traitsArray = [String]()
        self.traitByName = [String:PFObject]()
        
        traitQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["name"] as! String
                    self.traitsArray?.append(name)
                    self.traitByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadLoves() {
        let loveQuery = PFQuery(className:"Love")
        self.lovesArray = [String]()
//        self.loveByName = [String:PFObject]()
        
        loveQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["text"] as! String
                    self.lovesArray?.append(name)
//                    self.loveByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadHates() {
        let hateQuery = PFQuery(className:"Hate")
        self.hatesArray = [String]()
//        self.hateByName = [String:PFObject]()
        
        hateQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["text"] as! String
                    self.hatesArray?.append(name)
//                    self.hateByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadShelters() {
        let sheltersQuery = PFQuery(className:"Location")
        sheltersQuery.whereKey("type", equalTo: "shelter")

        self.sheltersArray = [String]()
        self.shelterByName = [String:PFObject]()
        
        sheltersQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["name"] as! String
                    self.sheltersArray?.append(name)
                    self.shelterByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadVets() {
        let vetsQuery = PFQuery(className:"Location")
        vetsQuery.whereKey("type", equalTo: "vet")
        
        self.vetsArray = [String]()
        self.vetByName = [String:PFObject]()
        
        vetsQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["name"] as! String
                    self.vetsArray?.append(name)
                    self.vetByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadBreeds() {
        let breedQuery = PFQuery(className:"Breed")
        self.breedsArray = [String]()
        self.breedByName = [String:PFObject]()
        
        breedQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let name = object["name"] as! String
                    self.breedsArray?.append(name)
                    self.breedByName![name] = object
                }
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface. 
        // FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
}