//
//  Extensions.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/12/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import CLImageEditor
import BTNavigationDropdownMenu
import IDMPhotoBrowser
import ALCameraViewController
import DZNEmptyDataSet

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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setUpNavigationBar() {
        self.setUpNavigationBar("")
    }
    
    func setUpNavigationBar(title: String) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        //nav?.barTintColor = UIColor.blueColor()
        nav?.tintColor = UIColor.whiteColor()
        
        nav?.setBackgroundImage(nil, forBarMetrics: .Default)
        if var frame = nav?.frame {
            frame.size.height = 40
            nav?.frame = frame
        }
        
        nav?.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 19)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationItem.title = title
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
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
    
    func showError(message: String) {
        view.dodo.topLayoutGuide = topLayoutGuide
        view.dodo.style.bar.hideOnTap = true
        view.dodo.style.bar.hideAfterDelaySeconds = 3
        
        let parentController: UIViewController? = self.parentViewController
        if (parentController != nil && parentController!.isKindOfClass(UIViewController)) {
            parentController!.view.dodo.error(message)
        } else {
            self.view.dodo.error(message)
        }
    }
    
    
    func takePhoto(delegate: protocol<CLImageEditorDelegate>) {
        let cameraViewController : ALCameraViewController = ALCameraViewController(croppingEnabled: true) { image in
            if image != nil {
                self.dismissViewControllerAnimated(false, completion: { () -> Void in
                })
                self.showEditor(image!, delegate: delegate, ratios: [["value1": 1, "value2": 1]])
            } else {
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
        cameraViewController.modalTransitionStyle = .CoverVertical
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func chooseImage(delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = delegate
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func showFlagActionSheet(sender: AnyObject, indexPath: NSIndexPath?, flaggedObject: PFObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Flag as", preferredStyle: .ActionSheet)
        
        let inappropriateAction = UIAlertAction(title: "Inappropriate", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.flagItem(flaggedObject, type: "inappropriate")
            print("Marked as inappropriate")
        })
        
        let spamAction = UIAlertAction(title: "Spam", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.flagItem(flaggedObject, type: "spam")
            print("Marked as spam")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(inappropriateAction)
        optionMenu.addAction(spamAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func flagItem(flaggedObject: PFObject, type: String) {
        let flag = PFObject(className: "Flag")
        
        if(flaggedObject.parseClassName == "AnimalTimelineEntry") {
            flag["entry"] = flaggedObject
        } else if(flaggedObject.parseClassName == "Comment") {
            flag["comment"] = flaggedObject
        }
        flag["type"] = type
        flag["reportedBy"] = PFUser.currentUser()
        
        self.showLoader()
        flag.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
            if(success) {
                NSLog("finished saving flag")
                self.displayAlert("Thanks for letting us know!  We'll take a look right away.")
            } else {
                NSLog("error saving flag")
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    func showProfilePhotoActionSheet(sender: AnyObject, delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate>) {
        
        let optionMenu = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting profile photo")
            self.takePhoto(delegate)
        })
        
        let imagePickerAction = UIAlertAction(title: "Choose a photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting cover photo")
            self.chooseImage(delegate)
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(imagePickerAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func openHashTagFeed(hashtag:String) -> () {
        let postsView = self.storyboard?.instantiateViewControllerWithIdentifier("PostsView") as! PostsTableViewController
        postsView.hashtag = hashtag
        self.navigationController?.pushViewController(postsView, animated: true)
    }
    
    func openAnimalDetail(username: String) -> () {
        let animalView = self.storyboard?.instantiateViewControllerWithIdentifier("AnimalDetailView") as! AnimalDetailViewController
        animalView.username = username
        self.navigationController?.pushViewController(animalView, animated: true)
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

extension String {
    func replace(target: String, withString: String) -> String {
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

extension UIImage {
    class func imageWithImage(image: UIImage, scaledToScale scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetInterpolationQuality(context, .High)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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


extension PFQueryTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {    
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