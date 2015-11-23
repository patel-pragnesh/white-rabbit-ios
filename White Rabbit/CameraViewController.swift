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
import GKImagePicker
import CLImageEditor


class CameraViewController: UIViewController, GKImagePickerDelegate, GKImageCropControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {

    var animalObject: PFObject?
    var pickedImageDate : NSDate?
    var imagePicker : GKImagePicker = GKImagePicker()
    var animalDetailController : AnimalDetailViewController?
    
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
//        self.displayAlert(imagePreview.frame.size.width.description)

        
//        self.imagePicker = GKImagePicker() //UIImagePickerController()
//        self.imagePicker.cropSize = CGSizeMake(320, 320)
//        self.imagePicker.delegate = self

        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        
        let cameraViewController : ALCameraViewController = ALCameraViewController(croppingEnabled: true) { image in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            if image != nil {
                self.imagePreview.image = image
                self.saveButton.enabled = true
                self.dismissViewControllerAnimated(true, completion: {})
            } else {
                self.dismissViewControllerAnimated(true, completion: {})
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
//        cameraViewController
        presentViewController(cameraViewController, animated: true, completion: nil)
        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .Camera
//        picker.allowsEditing = true
//        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imageCropController(imageCropController: GKImageCropViewController!, didFinishWithCroppedImage croppedImage: UIImage!) {
        self.imagePreview.contentMode = .ScaleAspectFill
        self.imagePreview.image = croppedImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        saveButton.enabled = true
    }
    
    func imagePicker(imagePicker: GKImagePicker!, pickedImage image: UIImage!) {
        self.imagePreview.contentMode = .ScaleAspectFill
        self.imagePreview.image = image
        
        dismissViewControllerAnimated(true, completion: nil)

        saveButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        NSLog("image picker cancelled")
        self.closeView()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let url: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        
        let library = ALAssetsLibrary()
        library.assetForURL(url,
            resultBlock: {
                (asset: ALAsset!) -> Void in
                if asset != nil {
                    let date = asset.valueForProperty(ALAssetPropertyDate)
                    self.pickedImageDate = date as? NSDate
                }
            }, failureBlock: { (error: NSError!) -> Void in
                print(error)
            }
        )

        let cropController = GKImageCropViewController()
        cropController.sourceImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        cropController.resizeableCropArea = false
        cropController.cropSize = CGSizeMake(320, 320)
        cropController.delegate = self
        picker.pushViewController(cropController, animated: true)
        
//        imagePreview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        dismissViewControllerAnimated(true, completion: nil)
//        saveButton.enabled = true
    }
    
    @IBAction func saveImage(sender: UIButton) {
        self.performSegueWithIdentifier("CameraToSavePhoto", sender: self)
        
//        self.saveImageData()
//        saveButton.enabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "CameraToSavePhoto") {
            let detailScene = segue.destinationViewController as! PhotoSaveViewController
            detailScene.image = self.imagePreview.image
            detailScene.animalObject = self.animalObject
            detailScene.pickedImageDate = self.pickedImageDate
            detailScene.previousViewController = self
        }
    }
    
    func clearImagePreview() {
        self.imagePreview.image = nil
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.closeView()
    }

    func closeView() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.animalDetailController!.reloadTimeline()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
