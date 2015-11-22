//
//  PhotoSaveViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit

class PhotoSaveViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var previousViewController : CameraViewController?
    
    var image : UIImage?
    var animalObject : PFObject?
    var pickedImageDate : NSDate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.image

        // Do any additional setup after loading the view.
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
                NSLog("error uploading file: \(error)")
            }
        }
    }

    func closeView() {
        self.previousViewController?.closeView()
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.previousViewController?.closeView()
            self.dismissViewControllerAnimated(true, completion: nil)
//            self.animalDetailController!.reloadTimeline()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
