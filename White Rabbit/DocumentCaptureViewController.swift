//
//  DocumentCaptureViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import IPDFCameraViewController
import Dollar
import Eureka

class DocumentCaptureViewController: UIViewController {

    @IBOutlet weak var flashButton: UIButton!

    @IBOutlet var cameraViewController: IPDFCameraViewController!
    
    var formViewController: PhotoSaveViewController?
    
    var document: PFObject?
    
    var currentImage: UIImage?
    var selectedImages: [UIImage!] = [UIImage!]()
    var previewImages: [UIButton!] = [UIButton!]()
    var currentPreview: UIImageView?
    
    let previewPadding = 10
    let previewWidth = 75
    
    @IBOutlet weak var adjustBar: UIView!
    
    @IBAction func flashButtonPressed(sender: AnyObject) {
        self.cameraViewController.enableTorch = !self.cameraViewController.enableTorch
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraViewController.setupCameraView()
        self.cameraViewController.enableBorderDetection = true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.cameraViewController.start()
    }
    
    func addImagePreview(image: UIImage, index: Int) {
        let minX = ((index * previewWidth) + ((index + 1) * (previewPadding / 2)))
        let minY = previewPadding / 2
        let height = self.adjustBar.frame.height - CGFloat(previewPadding)
        
        let imageView: UIButton = UIButton(frame: CGRectMake(CGFloat(minX), CGFloat(minY), CGFloat(previewWidth), CGFloat(height)))
        imageView.setImage(image, forState: .Normal)
        imageView.tag = index
        imageView.addTarget(self, action: "removeImage:", forControlEvents: .TouchUpInside)
        
        let removeImageButton: UIButton = UIButton(frame: CGRectMake(CGFloat(previewWidth - 10), -10, 20, 20))
        removeImageButton.setImage(UIImage(named: "image_close"), forState: .Normal)
        removeImageButton.tag = index
        removeImageButton.addTarget(self, action: "removeImage:", forControlEvents: .TouchUpInside)
        imageView.addSubview(removeImageButton)

        self.adjustBar.addSubview(imageView)
        previewImages.append(imageView)
    }
    
    
    
    func restackImagePreviews(fromIndex: Int) {
        if(fromIndex >= self.previewImages.count) {
            NSLog("not restacking")
            return
        }
        NSLog("restacking from: \(fromIndex)")
        let imagesToRestack = fromIndex == 0 ? Array(self.previewImages) : Array(self.previewImages.slice(fromIndex, -1))
        
        imagesToRestack.forEach { (element) -> Void in
            let imageButton = element
            imageButton.frame = CGRectMake(imageButton.frame.minX - CGFloat(self.previewWidth + self.previewPadding), imageButton.frame.minY, imageButton.frame.width, imageButton.frame.height)
            imageButton.tag = imageButton.tag - 1
            
        }
    }
    
    func removeImage(sender:UIButton!) {
        NSLog("removing image")
        
        self.selectedImages.removeAtIndex(sender.tag)
        self.previewImages[sender.tag].removeFromSuperview()
        self.previewImages.removeAtIndex(sender.tag)
        
        NSLog("preview images count: \(self.previewImages.count)")
        NSLog("selected images count: \(self.selectedImages.count)")
        self.restackImagePreviews(sender.tag)
    }
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func captureDocument(sender: AnyObject) {
        self.cameraViewController.captureImageWithCompletionHander { (object: AnyObject!) -> Void in
            let image = object as! UIImage
            
            self.currentImage = image
            
            let captureImageView: UIImageView = UIImageView(image: image)
            captureImageView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            captureImageView.frame = CGRectOffset(self.view.bounds, 0, -self.view.bounds.size.height)
            captureImageView.alpha = 1.0
            captureImageView.contentMode = .ScaleAspectFit
            captureImageView.userInteractionEnabled = true
            
            let addDocumentButton: UIButton = UIButton(frame: CGRectMake(captureImageView.frame.width / 2 - 75, captureImageView.frame.height - 200, 150, 150))
            addDocumentButton.addTarget(self, action: "savePage", forControlEvents: .TouchUpInside)
            addDocumentButton.setImage(UIImage(named: "document_add_button"), forState: .Normal)
            
            captureImageView.addSubview(addDocumentButton)
            self.view.addSubview(captureImageView)
            
            let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissPreview:")
            captureImageView.addGestureRecognizer(dismissTap)
            self.currentPreview = captureImageView
            UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .AllowUserInteraction, animations: {() -> Void in
                captureImageView.frame = self.view.bounds
                }, completion: nil)
            
        }
        
    }
    
    @IBAction func saveDocuments(sender: AnyObject) {
        if(self.selectedImages.count > 0) {
            
            let document = PFObject(className: "Document")
            document["title"] = "New Document"

            self.showLoader()
            document.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.document = document
                self.selectedImages.forEach { (element) -> Void in
                    let image: UIImage = element
                    self.saveDocument(image)
                }
                self.hideLoader()
                
                let row = self.formViewController!.form.rowByTag("documents") as! DocumentsRow
                row.documents.append(document)
                
                let index = 0
                let minX = ((index * self.previewWidth) + ((index + 1) * (self.previewPadding / 2)))
                let minY = self.previewPadding / 2
                let height = row.cell.documentsStackView.frame.height - CGFloat(self.previewPadding)
                
                let imageView: UIButton = UIButton(frame: CGRectMake(CGFloat(minX), CGFloat(minY), CGFloat(self.previewWidth), CGFloat(height)))
                imageView.setImage(self.selectedImages[0], forState: .Normal)
                imageView.tag = index
                imageView.addTarget(self, action: "removeDocument:", forControlEvents: .TouchUpInside)
                
                row.addDocumentView(imageView)
                
                self.closeView(self)
            })
            
        } else {
            self.closeView(self)
        }
    }
    
    func saveDocument(image: UIImage) {
        let page = PFObject(className: "DocumentPage")
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageFile:PFFile = PFFile(name: "document.jpg", data: imageData!)!
        
        page["page"] = imageFile
        page["document"] = self.document
        
        page.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
            } else {
                self.view.dodo.error((error?.localizedDescription)!)
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.cameraViewController.enableTorch = false
    }

    
    func savePage() {
        self.dismissPreview()
        
        self.selectedImages.append(self.currentImage)
        self.addImagePreview(self.currentImage!, index: (self.selectedImages.count - 1))
    }
    
    func dismissPreview() {
        self.currentPreview!.removeFromSuperview()
    }
    
    func dismissPreview(dismissTap: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {() -> Void in
            dismissTap.view!.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height)
            }, completion: {(finished: Bool) -> Void in
                self.currentImage = nil
                dismissTap.view!.removeFromSuperview()
        })
    }
}
