//
//  TimelineEntryDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import ActiveLabel

class TimelineEntryDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: ActiveLabel!
    @IBOutlet weak var documentsView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLink: UIButton!
    @IBOutlet weak var profilePhotoButton: UIButton!
    
    @IBOutlet weak var commentAnimalProfilePhoto: UIButton!
    @IBOutlet weak var commentToolbar: UIToolbar!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var commentToolbarBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var documentsWidthConstraint: NSLayoutConstraint!
    
    var entryObject : PFObject?
    var commentsView : TimelineEntryCommentsViewController?

    var documents : [[UIImage!]]?
    
    let previewPadding = 20
    let previewWidth = 125
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasHidden:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentField.delegate = self

        self.navigationItem.rightBarButtonItem = self.getNavBarItem("share_white", action: "showShareActionSheet", height: 45, width: 35)
        self.setUpNavigationBar()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.setAnimalToComment(0)
        
        self.textLabel.handleHashtagTap(self.openHashTagFeed)
        self.textLabel.handleMentionTap(self.openAnimalDetail)

        self.textLabel.text = entryObject?["text"] as? String
        
        if let imageFile = entryObject?["image"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.imageView.image = image
                }
            })
        }
        
        if let date = entryObject!.valueForKey("createdAt") as? NSDate {
            let formatted = date.toRelativeString(fromDate: NSDate(), abbreviated: true, maxUnits:1)
            self.timeLabel.text = formatted
        }
        
        let animalObject = entryObject?.objectForKey("animal") as? PFObject
        self.usernameLink.setTitle(animalObject!.valueForKey("username") as? String, forState: .Normal)
        
        if let profilePhotoFile = animalObject!["profilePhoto"] as? PFFile {
            profilePhotoFile.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.profilePhotoButton.setImage(image?.circle, forState: .Normal)
                }
            })
        }
        
        
        if(entryObject?.objectForKey("hasDocuments") != nil && entryObject?.objectForKey("hasDocuments") as! Bool) {
            self.loadDocuments()
        }
    }
    
    func setAnimalToComment(index: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.myAnimalsArray!.count > 0) {
            let animalToComment = appDelegate.myAnimalsArray![index]
            
            if let profilePhotoFile = animalToComment["profilePhoto"] as? PFFile {
                profilePhotoFile.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.commentAnimalProfilePhoto.setImage(image?.circle, forState: .Normal)
                        self.commentAnimalProfilePhoto.tag = index
                    }
                })
            }
        }
    }
    
    func showAnimalToCommentSheet() {
        let optionMenu = UIAlertController(title: nil, message: "Comment as:", preferredStyle: .ActionSheet)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        for animal in appDelegate.myAnimalsArray! {
            let username = animal.valueForKey("name") as? String
            let animalAction = UIAlertAction(title: username, style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in

                self.setAnimalToComment(appDelegate.myAnimalsArray!.indexOf(animal)!)
            })

            optionMenu.addAction(animalAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)

        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }
    
    @IBAction func commentAnimalProfilePhotoPressed(sender: AnyObject) {
        self.showAnimalToCommentSheet()
    }
    
    func loadDocuments() {
        self.documents = [[UIImage!]]()

        let documentQuery = PFQuery(className: "Document")
        documentQuery.whereKey("entry", equalTo: entryObject!)
        
        documentQuery.findObjectsInBackgroundWithBlock({ (documents: [PFObject]?, error: NSError?) -> Void in
            if(error == nil) {
                documents?.forEach({ (element: PFObject) -> Void in
                    let document = PFObject(withoutDataWithClassName: "Document", objectId: element.objectId)
                    
                    let index = self.documents!.count
                    self.documents!.append([UIImage!]())
                    
                    let pagesQuery = PFQuery(className: "DocumentPage")
                    pagesQuery.whereKey("document", equalTo: document)
                    
                    pagesQuery.findObjectsInBackgroundWithBlock({ (pages: [PFObject]?, error: NSError?) -> Void in
                        if(error == nil) {
                            
                            pages?.forEach({ (pageObject: PFObject) -> Void in
                                let page = pageObject.objectForKey("page") as? PFFile
                                
                                page!.getDataInBackgroundWithBlock({
                                    (imageData: NSData?, error: NSError?) -> Void in
                                    if(error == nil) {
                                        let image = UIImage(data:imageData!)
                                        
                                        self.documents![index].append(image)
                                        self.updateDocumentsView()
                                    }
                                })
                            })
                            
                        }
                    })
                })
            } else {
                self.showError(error!.localizedDescription)
            }
        })
    }
    
    func updateDocumentsView() {
        for view in documentsView.subviews{
            view.removeFromSuperview()
        }
        var index = 0
        self.documents!.forEach { (document) -> Void in
            if document.count > 0 {
                self.addDocumentView(document[0], index: index)
                index++
            }
        }
        let frameWidth = (self.documents!.count * (self.previewWidth + self.previewPadding)) - self.previewPadding
        documentsWidthConstraint.constant = CGFloat(frameWidth) - self.view.bounds.width
    }
    
    func addDocumentView(image: UIImage, index: Int) {
         let frame = self.getImageThumbnailFrame(image, index: index, parentFrame: self.documentsView.frame, previewWidth: self.previewWidth, previewPadding: self.previewPadding)
        
        let imageView: UIButton = UIButton(frame: frame)
        imageView.setImage(image, forState: .Normal)
        imageView.tag = index

        imageView.addTarget(self, action: "showBrowser:", forControlEvents: .TouchUpInside)
        
        self.documentsView.addSubview(imageView)
    }
    
    func showBrowser(sender: UIButton!) {
        let images: [UIImage!] = documents![sender.tag]
        self.showImagesBrowser(images, animatedFromView: sender)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.goBack()
            default:
                break
            }
        }
    }
        
    func showShareActionSheet() {
        let image = self.imageView.image
        let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image!], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func addComment(text: String) {
        self.showLoader()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.myAnimalsArray?.count > 0) {
            let comment = PFObject(className: "Comment")
            comment.setObject(self.entryObject!, forKey: "entry")
            
            let animalIndex = self.commentAnimalProfilePhoto.tag
            comment.setObject(appDelegate.myAnimalsArray![animalIndex], forKey: "animal")
            
            comment.setValue(text, forKey: "text")
            comment.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if(error == nil) {
                    self.commentsView?.loadObjects()
                    self.hideLoader()
                }
            }
        } else {
            self.hideLoader()
            self.showError("Add a cat to make a comment")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.sendWasPressed()
        return true
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.commentToolbarBottomContraint.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWasHidden(notification: NSNotification) {
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.commentToolbarBottomContraint.constant = 0
        })
    }
    
    @IBAction func sendWasPressed() {
        if(self.commentField.text == "") {
            self.commentField.resignFirstResponder()
        } else {
            self.addComment(self.commentField.text!)
            self.commentField.resignFirstResponder()
            self.commentField.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "EntryDetailCommentsEmbed") {
            let commentsView = segue.destinationViewController as! TimelineEntryCommentsViewController
            commentsView.entryObject = self.entryObject
            self.commentsView = commentsView
        }
    }
}
