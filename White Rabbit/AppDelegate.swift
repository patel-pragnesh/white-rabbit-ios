//
//  AppDelegate.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseCrashReporting
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit
import CLImageEditor
import ParseFacebookUtilsV4
import ParseTwitterUtils
import SlideMenuControllerSwift
import BTNavigationDropdownMenu
import ContentfulDeliveryAPI
import FillableLoaders
import IDMPhotoBrowser


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: CDAClient?
    
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
        
        loadMainController()
        loadTraits()
        loadBreeds()
        loadShelters()
        loadVets()
        loadLoves()
        loadHates()
        loadCoats()
        
        return true
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
                NSLog("Finished loading coats: %@", self.coatByName!)
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
                NSLog("Finished loading traits: %@", self.traitByName!)
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
//                NSLog("Finished loading loves: %@", self.loveByName!)
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
//                NSLog("Finished loading hates: %@", self.hateByName!)
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
                NSLog("Finished loading shelters: %@", self.shelterByName!)
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
                NSLog("Finished loading vets: %@", self.vetByName!)
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
                NSLog("Finished loading breeds: %@", self.breedByName!)
            } else {
                NSLog("Error: %@", error!)
            }
        }
    }
    
    func loadMainController() {
        var storyboard = self.window?.rootViewController?.storyboard
        if(storyboard == nil) {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        let homeController = storyboard?.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
        homeController.checkForUser(false)
//        let mainController = storyboard?.instantiateViewControllerWithIdentifier("AnimalsNavigation")
        let mainController = storyboard?.instantiateViewControllerWithIdentifier("PostsNavigation")
        homeController.mainViewController = mainController
        
        let slideMenuController = SlideMenuController(mainViewController: mainController!, leftMenuViewController: homeController)
        
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
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

private var currentPreview: UIImageView?

extension UIViewController {
    func showLoader() {
        let filename = Int.random(1, upper: 7)
        
        GiFHUD.setGif("gif/" + String(filename) + ".gif")
        GiFHUD.show()
    }
    
    func hideLoader() {
        GiFHUD.dismiss()
    }
    
//    func getCurrentUser() -> PFObject {
//        let userQuery : PFQuery = PFUser.query()!
//        userQuery.includeKey("shelter")
//        
//        do {
//            let user: PFObject = try userQuery.getObjectWithId((PFUser.currentUser()?.objectId)!)
//            return user
//        } catch _ {
//        }
////        return nil
//    }
    
    func getNavBarItem(imageId : String, action : Selector, height : CGFloat, width: CGFloat) -> UIBarButtonItem! {
        let editImage = UIImage(named: imageId)
        let editButton = UIButton(type: .Custom)
        editButton.setImage(editImage, forState: .Normal)
        editButton.frame = CGRectMake(0, 0, width, height)
        editButton.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: editButton)
    }
    
    func getNavBarItem(imageId : String, height : CGFloat, width: CGFloat) -> UIBarButtonItem! {
        let editImage = UIImage(named: imageId)
        let editButton = UIButton(type: .Custom)
        editButton.setImage(editImage, forState: .Normal)
        editButton.frame = CGRectMake(0, 0, width, height)
        return UIBarButtonItem(customView: editButton)
    }


    func setUpNavigationBar() {
        self.setUpNavigationBar("")
    }
    
    func setUpNavigationBar(title: String) {
        let nav = self.navigationController?.navigationBar
        nav!.barStyle = UIBarStyle.BlackTranslucent
        //nav?.barTintColor = UIColor.blueColor()
        nav!.tintColor = UIColor.whiteColor()
        
        nav!.setBackgroundImage(nil, forBarMetrics: .Default)
        var frame = nav!.frame
        frame.size.height = 40
        nav!.frame = frame
        
        nav!.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 19)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
//        self.navigationItem.toggleBoldface(self)
        
        self.navigationItem.title = title
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func removeNavigationBar() {
//        let nav = self.navigationController?.navigationBar
//        nav!.delete(self)
    }
    
    func setUpNavigationBarImage(image: UIImage, height: CGFloat) {
        let nav = self.navigationController?.navigationBar

        nav?.barStyle = UIBarStyle.Default

        nav!.setBackgroundImage(image.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: .Default)
        var frame = nav!.frame
        frame.size.height = height
        nav!.frame = frame
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
    }
    
    func setUpMenuBarController() {
        self.setUpMenuBarController("")
    }
    
    func setUpMenuBarController(title: String) {
        self.setUpNavigationBar(title)
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("menu_white", action: "showMenu", height: 15, width: 25)
    }
    
    func showMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func getImageThumbnailFrame(image: UIImage, index: Int, parentFrame: CGRect, previewWidth: Int, previewPadding: Int) -> CGRect {
        let extra = ((index + 1) * (previewPadding / 2))
        var minX:CGFloat = CGFloat(((index * previewWidth) + extra))
        var width = CGFloat(previewWidth)
        let fullHeight = parentFrame.height - CGFloat(previewPadding)
        var height = image.size.height / (image.size.width / CGFloat(width))
        var minY = CGFloat(previewPadding / 2) + ((fullHeight - height) / 2)
        
        if(height > fullHeight) {
            height = parentFrame.height - CGFloat(previewPadding)
            width = image.size.width / (image.size.height / height)
            minY = CGFloat(previewPadding / 2)
            minX = CGFloat(minX) + ((CGFloat(previewWidth) - width) / 2)
        }
        
        return CGRectMake(CGFloat(minX), CGFloat(minY), CGFloat(width), CGFloat(height))
    }
    
    func showEditor(image : UIImage, delegate: CLImageEditorDelegate, var ratios: [AnyObject]?) {
        let editor = CLImageEditor(image: image)
        editor.delegate = delegate
        
        let stickerTool = editor.toolInfo.subToolInfoWithToolName("CLStickerTool", recursive: false)
//        stickerTool.optionalInfo["stickerPath"] = "/edit_stickers/"
        
        stickerTool.optionalInfo["flipHorizontalIconAssetsName"] = "button_stickers"
        stickerTool.available = true
        
        let splashTool = editor.toolInfo.subToolInfoWithToolName("CLSplashTool", recursive: false)
        splashTool.available = false
        
        let curveTool = editor.toolInfo.subToolInfoWithToolName("CLToneCurveTool", recursive: false)
        curveTool.available = false
        let blurTool = editor.toolInfo.subToolInfoWithToolName("CLBlurTool", recursive: false)
        blurTool.available = false
        let drawTool = editor.toolInfo.subToolInfoWithToolName("CLDrawTool", recursive: false)
        drawTool.available = false
        let adjustmentTool = editor.toolInfo.subToolInfoWithToolName("CLAdjustmentTool", recursive: false)
        adjustmentTool.available = false
        
        let effectTool = editor.toolInfo.subToolInfoWithToolName("CLEffectTool", recursive: false)
        effectTool.available = false
        let pixelateFilter = effectTool.subToolInfoWithToolName("CLPixellateEffect", recursive: false)
        pixelateFilter.available = false
        let posterizeFilter = effectTool.subToolInfoWithToolName("CLPosterizeEffect", recursive: false)
        posterizeFilter.available = false
        
        
        let filterTool = editor.toolInfo.subToolInfoWithToolName("CLFilterTool", recursive: false)
//        filterTool.optionalInfo["flipHorizontalIconAssetsName"] = "button_filter"
        filterTool.available = true
        let invertFilter = filterTool.subToolInfoWithToolName("CLDefaultInvertFilter", recursive: false)
        invertFilter.available = false
        
        let rotateTool = editor.toolInfo.subToolInfoWithToolName("CLRotateTool", recursive: false)
        rotateTool.available = true
        rotateTool.dockedNumber = -1
        
        let cropTool = editor.toolInfo.subToolInfoWithToolName("CLClippingTool", recursive: false)
        cropTool.optionalInfo["flipHorizontalIconAssetsName"] = "button_crop"
        cropTool.available = true
        cropTool.dockedNumber = -2
        cropTool.optionalInfo["swapButtonHidden"] = true
        
        if ratios == nil {
            ratios = [["value1": 1, "value2": 1]]
        }
        cropTool.optionalInfo["ratios"] = ratios
        
        editor.modalTransitionStyle = .CoverVertical
        self.presentViewController(editor, animated: true, completion: nil)
    }
    
    func displayAlert(title:String, message:String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlert(message: String) {
        displayAlert("Alert", message: message, buttonText: "OK")
    }
    
    private struct GlobalViews {
        private var currentPreview: UIImageView?
    }
    
    func showFullScreen(sender: UIButton!) {
        NSLog("fullscreening image")
        let image = sender.imageView?.image
        NSLog("fullscreening image \(image)")
        self.showImageFullScreen(image!, animatedFromView: sender)
    }
    
    func showImageFullScreen(image: UIImage, animatedFromView: UIView) {
        self.showImagesBrowser([image], animatedFromView: animatedFromView)
    }
    
    func showImagesBrowser(images: [UIImage!], animatedFromView: UIView) {
        var idmImages = Array<IDMPhoto>()
        images.forEach { (image) -> Void in
            let idmPhoto : IDMPhoto = IDMPhoto(image: image)
            idmImages.append(idmPhoto)
        }
        let browser: IDMPhotoBrowser! = IDMPhotoBrowser(photos: idmImages, animatedFromView: animatedFromView)
        browser.displayActionButton = true
        browser.displayArrowButton = true
        browser.displayCounterLabel = false
        browser.usePopAnimation = true
        browser.doneButtonImage = UIImage(named: "close_white")
        self.presentViewController(browser, animated: true, completion: nil)
    }
    
    
    func dismissPreview(sender: AnyObject) {
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {() -> Void in
                if (currentPreview != nil) {
                    currentPreview!.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height)
                } else if (sender is UIImageView) {
                } else if (sender is UITapGestureRecognizer || sender is UIButton){
                    sender.view!.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height)
                }
            }, completion: {(finished: Bool) -> Void in
                if (sender is UIImageView) {
                    sender.removeFromSuperview()
                } else if (currentPreview != nil) {
                    currentPreview!.removeFromSuperview()
                } else if (sender is UITapGestureRecognizer || sender is UIButton){
                    sender.view!.removeFromSuperview()

                    NSLog("Don't know what to dismiss.")
                }
        })
    }
 
    
    //    func dismissPreview(dismissTap: UITapGestureRecognizer) {
    //        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {() -> Void in
    //            dismissTap.view!.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height)
    //            }, completion: {(finished: Bool) -> Void in
    //                self.currentImage = nil
    //                dismissTap.view!.removeFromSuperview()
    //        })
    //    }

    
    func openUrl(url:String!) {
        NSLog("opening url: \(url)")
        
        let url = NSURL(string: url)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func openAppLinkOrWebUrl(appLink: String!, webUrl: String!) {
        if(UIApplication.sharedApplication().canOpenURL(NSURL(string: appLink)!)) {
            openUrl(appLink)
        } else {
            openUrl(webUrl)
        }
    }

    
    
}

public extension UITextField {
    @IBInspectable public var leftSpacer:CGFloat {
        get {
            if let l = leftView {
                return l.frame.size.width
            } else {
                return 0
            }
        } set {
            leftViewMode = .Always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSFontAttributeName : font]
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.ByWordWrapping
        let rect = text!.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        heightConstraint.constant = rect.height
        setNeedsLayout()
    }
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
    }

}

extension UIImage
{
    class func imageWithImage(image: UIImage, scaledToScale scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetInterpolationQuality(context, .High)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func roundImage() -> UIImage
    {
        let newImage = self.copy() as! UIImage
        let cornerRadius = self.size.width / 2
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        let bounds = CGRect(origin: CGPointZero, size: self.size)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        newImage.drawInRect(bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    var rounded: UIImage {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = size.height < size.width ? size.height/2 : size.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = square.width/50
        imageView.layer.borderColor = CGColorCreateCopyWithAlpha(UIColor.whiteColor().CGColor, 0.75)
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}


extension PFQueryTableViewController {
    func stylePFLoadingView() {
        let activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // go through all of the subviews until you find a PFLoadingView subclass
        for view in self.view.subviews {
            if NSStringFromClass(view.classForCoder) == "PFLoadingView" {
                // find the loading label and loading activity indicator inside the PFLoadingView subviews
                for loadingViewSubview in view.subviews {
                    if loadingViewSubview is UILabel {
                        let label:UILabel = loadingViewSubview as! UILabel
                        let frame = label.frame
                        label.frame = CGRect(x: frame.midX, y: frame.midY, width: 100, height: 20)
                        //                        label.textColor = labelTextColor
                        //                        label.shadowColor = labelShadowColor
                    }
                    
                    
                    if loadingViewSubview is UIActivityIndicatorView {
//                        let view  = UIActivityIndicatorView()
//                        view.addSubview(GiFHUD.instance.imageView!)
                        
                        let indicator:UIActivityIndicatorView = loadingViewSubview as! UIActivityIndicatorView
                        indicator.activityIndicatorViewStyle = activityIndicatorViewStyle
                    }
                }
                
            }
        }
    }
    
}

public extension Int {
    public static func random (lower: Int , upper: Int) -> Int {
        let limit = UInt32(upper - lower + 1)
        return lower + Int(arc4random_uniform(limit))
    }
}

extension Array {
    func forEach(doThis: (element: Element) -> Void) {
        for e in self {
            doThis(element: e)
        }
    }
    
    func slice(args: Int...) -> Array {
        var s = args[0]
        var e = self.count - 1
        if args.count > 1 { e = args[1] }
        
        if e < 0 {
            e += self.count
        }
        
        if s < 0 {
            s += self.count
        }
        
        let count = (s < e ? e-s : s-e)+1
        let inc = s < e ? 1 : -1
        var ret = Array()
        
        var idx = s
        for var i=0;i<count;i++  {
            ret.append(self[idx])
            idx += inc
        }
        return ret
    }
}