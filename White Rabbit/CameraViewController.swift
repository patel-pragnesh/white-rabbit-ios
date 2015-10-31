//
//  CameraViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse
import ALCameraViewController
import AssetsLibrary
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var animalObject: PFObject?
    var pickedImageDate : NSDate?
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var uploadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadIndicator.hidden = true

        // Do any additional setup after loading the view.
    }

    @IBAction func chooseImage(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func takePhoto(sender: UIButton) {
        
        let cameraViewController = ALCameraViewController(croppingEnabled: true) { image in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self.imagePreview.image = image
            self.dismissViewControllerAnimated(true, completion: {})
            self.saveButton.enabled = true
        }
//        cameraViewController
        presentViewController(cameraViewController, animated: true, completion: nil)
        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .Camera
//        picker.allowsEditing = true
//        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePreview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let url: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        
        let library = ALAssetsLibrary()
        library.assetForURL(url,
            resultBlock: {
                (asset: ALAsset!) -> Void in
                    let date = asset.valueForProperty(ALAssetPropertyDate)
                    self.pickedImageDate = date as! NSDate
            }, failureBlock: { (error: NSError!) -> Void in
                print(error)
            }
        )
        
        dismissViewControllerAnimated(true, completion: nil)
        saveButton.enabled = true
    }
    
    @IBAction func saveImage(sender: UIButton) {
        self.saveImageData()
        saveButton.enabled = false
    }
    
    func saveImageData() {
        uploadIndicator.hidden = false
        uploadIndicator.startAnimating()
        
        let imageData = UIImageJPEGRepresentation(imagePreview.image!, 0.5)
        let fileName:String = (String)(PFUser.currentUser()!.username!) + "-" + (String)(NSDate().description.replace(" ", withString:"_").replace(":", withString:"-").replace("+", withString:"~")) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        let timelineEntry = PFObject(className: "AnimalTimelineEntry")
        timelineEntry["animal"] = self.animalObject
        timelineEntry["image"] = imageFile
        timelineEntry["createdBy"] = PFUser.currentUser()
        timelineEntry["kind"] = 1 // TODO : change this for a constant
        
        if self.pickedImageDate != nil {
            timelineEntry["date"] = self.pickedImageDate
        } else {
            timelineEntry["date"] = NSDate()
        }
        
        
        timelineEntry.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                NSLog("finished saving post")
                self.uploadIndicator.hidden = true
                self.uploadIndicator.stopAnimating()
                self.clearImagePreview()
                self.closeView()
            } else {
                NSLog("error uploading file: \(error)")
            }
        }
    }
    
    func showPostsView() {
        self.performSegueWithIdentifier("cameraPostsSegue", sender: self)
    }
    
    func clearImagePreview() {
        self.imagePreview.image = nil
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.closeView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
