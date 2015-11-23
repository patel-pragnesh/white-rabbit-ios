//
//  PhotoSaveViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Dodo

class PhotoSaveViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextView!
    
    let captionPlaceholder = "Enter caption here..."
    
    var previousViewController : CameraViewController?
    
    var image : UIImage?
    var animalObject : PFObject?
    var pickedImageDate : NSDate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.image
        
        captionTextField.delegate = self
        captionTextField.text = self.captionPlaceholder
        captionTextField.textColor = UIColor.lightGrayColor()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if captionTextField.textColor == UIColor.lightGrayColor() {
            captionTextField.text = ""
            captionTextField.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if captionTextField.text == "" {
            captionTextField.text = self.captionPlaceholder
            captionTextField.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        self.captionTextField.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        self.saveImageData()
    }

    
    func saveImageData() {
//        uploadIndicator.hidden = false
//        uploadIndicator.startAnimating()
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
        let fileName:String = (String)(PFUser.currentUser()!.username!) + "-" + (String)(NSDate().description.replace(" ", withString:"_").replace(":", withString:"-").replace("+", withString:"~")) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        let timelineEntry = PFObject(className: "AnimalTimelineEntry")
        timelineEntry["animal"] = self.animalObject
        timelineEntry["image"] = imageFile
        if(self.captionTextField.text != self.captionPlaceholder) {
            timelineEntry["text"] = self.captionTextField.text
        }
        timelineEntry["createdBy"] = PFUser.currentUser()
        timelineEntry["type"] = "image"
        
        if self.pickedImageDate != nil {
            timelineEntry["date"] = self.pickedImageDate
        } else {
            timelineEntry["date"] = NSDate()
        }
        
        timelineEntry.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                NSLog("finished saving post")
//                self.uploadIndicator.hidden = true
//                self.uploadIndicator.stopAnimating()
//                self.clearImagePreview()
                self.closeView()
            } else {
                NSLog("error uploading file: \(error?.localizedDescription)")
                self.view.dodo.error((error?.localizedDescription)!)
                self.closeView()
            }
        }
    }

    func closeView() {
        self.previousViewController?.closeView()
        self.previousViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.previousViewController!.animalDetailController!.reloadTimeline()
        }
    }
}
