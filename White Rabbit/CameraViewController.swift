//
//  CameraViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var uploadIndicator: UIActivityIndicatorView!
    
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        // picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePreview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)
        
        let post = PFObject(className: "Post")
        post["image"] = imageFile
        post["user"] = PFUser.currentUser()
        post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                NSLog("finished saving post")
                self.uploadIndicator.hidden = true
                self.uploadIndicator.stopAnimating()
                self.clearImagePreview()
                self.showPostsView()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
