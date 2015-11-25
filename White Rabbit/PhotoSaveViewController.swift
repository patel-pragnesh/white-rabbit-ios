//
//  PhotoSaveViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Dodo
import Eureka

class PhotoSaveViewController: FormViewController {

//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var captionTextField: UITextView!
    
//    let captionPlaceholder = "Enter caption here..."
    
    var previousViewController : CameraViewController?
    
    var image : UIImage?
    var animalObject : PFObject?
    var pickedImageDate : NSDate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBar()
        
//        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "closeView", height: 25, width: 25)
        
        self.generateForm()
        
//        captionTextField.delegate = self
//        captionTextField.text = self.captionPlaceholder
//        captionTextField.textColor = UIColor.lightGrayColor()
    }
    
    
    func generateForm() {
        form +++= Section("")
            <<< DateRow("date") {
                $0.title = "Date"
                $0.value = self.pickedImageDate != nil ? self.pickedImageDate : NSDate()
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_date")
            }
            <<< ImageRow("photo") {
                $0.title = "Photo"
                $0.value = self.image
                $0.disabled = true
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_cover_photo")
                    cell.height = { 200 }
            }
            <<< TextAreaRow("text") {
                $0.title = "Caption"
//                $0.value = self.pickedImageDate
                $0.placeholder = "Enter caption here..."
                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "form_username")
        }
            
        form +++= Section("Share")
            <<< SwitchRow("facebook") {
                $0.title = "Share to Facebook"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_facebook")
        }
            <<< SwitchRow("twitter") {
                $0.title = "Share to Twitter"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_twitter")
        }
    }
    
    func generateMedicalForm() {
        form +++= Section("")
            <<< DateRow("date") {
                $0.title = "Date"
                $0.value = self.pickedImageDate != nil ? self.pickedImageDate : NSDate()
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_date")
            }
            <<< TextAreaRow("text") {
                $0.title = "Caption"
                //                $0.value = self.pickedImageDate
                $0.placeholder = "Enter caption here..."
                }.cellSetup { cell, row in
                    //                    cell.imageView?.image = UIImage(named: "form_username")
        }
    }
    
    
//    func textViewDidBeginEditing(textView: UITextView) {
//        
//        if captionTextField.textColor == UIColor.lightGrayColor() {
//            captionTextField.text = ""
//            captionTextField.textColor = UIColor.blackColor()
//        }
//    }
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        if captionTextField.text == "" {
//            captionTextField.text = self.captionPlaceholder
//            captionTextField.textColor = UIColor.lightGrayColor()
//        }
//    }
//    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//    
//    func textViewShouldReturn(textField: UITextField) -> Bool {
//        self.captionTextField.endEditing(true)
//        return false
//    }

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

        let timelineEntry = PFObject(className: "AnimalTimelineEntry")
        timelineEntry["animal"] = self.animalObject
        
        if let imageValue = self.form.rowByTag("photo")?.baseValue as? UIImage {
            let imageData = UIImageJPEGRepresentation(imageValue, 0.5)
            let fileName:String = (String)(PFUser.currentUser()!.username!) + "-" + (String)(NSDate().description.replace(" ", withString:"_").replace(":", withString:"-").replace("+", withString:"~")) + ".jpg"
            let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
            
            timelineEntry["image"] = imageFile
        }
        
        if let textValue = self.form.rowByTag("text")?.baseValue as? String {
            timelineEntry["text"] = textValue
        }
        if let dateValue = self.form.rowByTag("date")?.baseValue as? NSDate {
            timelineEntry["date"] = dateValue
        }
        
        timelineEntry["createdBy"] = PFUser.currentUser()
        timelineEntry["type"] = "image"
        
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
