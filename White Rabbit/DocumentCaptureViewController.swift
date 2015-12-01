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

public class DocumentCell: Cell<Set<PFObject>>, CellType {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var documentsStackView: UIScrollView!
    
    public override func setup() {
        height = { 120 }
        row.title = nil
        super.setup()
    }
}

public final class DocumentsRow: Row<Set<PFObject>, DocumentCell>, RowType {
    var documents: [PFObject!] = [PFObject!]()
    var documentViews: [UIButton!] = [UIButton!]()
        
    public func addDocumentView(imageView: UIButton) {
        let cell = self.cell as DocumentCell
        cell.documentsStackView.addSubview(imageView)
        
        //        imageView.addTarget(self, action: "selectedImage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.documentViews.append(imageView)
    }
    
    public func removeDocumentView(index: Int) {
        self.documentViews[index].removeFromSuperview()
        self.documentViews.removeAtIndex(index)
        self.documents.removeAtIndex(index)
    }
    
    func selectedImage(sender: NSObject) {
        NSLog("Image tapped")
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        //        displayValueFor = nil
        cellProvider = CellProvider<DocumentCell>(nibName: "DocumentCell")
    }
}

class DocumentCaptureViewController: UIViewController {

    @IBOutlet weak var flashButton: UIButton!

    @IBOutlet var cameraViewController: IPDFCameraViewController!
    
    var formViewController: TimelineEntryFormViewController?
    
    var document: PFObject?
    
    var currentImage: UIImage?
    var selectedImages: [UIImage!] = [UIImage!]()
    var previewImages: [UIButton!] = [UIButton!]()
    var currentPreview: UIImageView?
    
    let previewPadding = 10
    let previewWidth = 75
    
    @IBOutlet weak var adjustBar: UIView!
    
    @IBOutlet weak var savePagesButton : UIButton!
    
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
        imageView.userInteractionEnabled = true
        imageView.addTarget(self, action: "showFullScreen:", forControlEvents: .TouchUpInside)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: "removeImage:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        imageView.addGestureRecognizer(swipeUp)

        
//        let removeImageButton: UIButton = UIButton(frame: CGRectMake(CGFloat(previewWidth - 10), -10, 20, 20))
//        removeImageButton.setImage(UIImage(named: "image_close"), forState: .Normal)
//        removeImageButton.tag = index
        
//        removeImageButton.addGestureRecognizer(swipeUp)
        
//        removeImageButton.addTarget(self, action: "removeImage:", forControlEvents: .TouchUpInside)
//        imageView.addSubview(removeImageButton)

        self.savePagesButton.enabled = true
        
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
    
    func removeImage(sender:UIGestureRecognizer!) {
        NSLog("removing image")
        
        self.selectedImages.removeAtIndex(sender.view!.tag)
        self.previewImages[sender.view!.tag].removeFromSuperview()
        self.previewImages.removeAtIndex(sender.view!.tag)
        
        NSLog("preview images count: \(self.previewImages.count)")
        NSLog("selected images count: \(self.selectedImages.count)")
        self.restackImagePreviews(sender.view!.tag)
    }
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func captureDocument(sender: AnyObject) {
        self.cameraViewController.captureImageWithCompletionHander { (object: AnyObject!) -> Void in
            let image = object as! UIImage
            self.currentImage = image
            self.showImageFullScreen(image, showAddButton: true)
        }
        
    }
    
    @IBAction func savePages(sender: AnyObject) {
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
                
                let index = (self.formViewController?.getDocuments().count)! - 1
                let minX = ((index * self.previewWidth) + ((index + 1) * (self.previewPadding / 2)))
                let minY = self.previewPadding / 2
                let height = row.cell.documentsStackView.frame.height - CGFloat(self.previewPadding)
                
                let imageView: UIButton = UIButton(frame: CGRectMake(CGFloat(minX), CGFloat(minY), CGFloat(self.previewWidth), CGFloat(height)))
                imageView.setImage(self.selectedImages[0], forState: .Normal)
                imageView.tag = index
                imageView.userInteractionEnabled = true
                
                let swipeUp = UISwipeGestureRecognizer(target: self, action: "removeDocument:")
                swipeUp.direction = UISwipeGestureRecognizerDirection.Up
                imageView.addGestureRecognizer(swipeUp)
                
//                imageView.addTarget(self, action: "removeDocument:", forControlEvents: .TouchUpInside)
                imageView.addTarget(self.formViewController, action: "showFullScreen:", forControlEvents: .TouchUpInside)

                row.addDocumentView(imageView)
                
                self.closeView(self)
            })
            
        } else {
            self.closeView(self)
        }
    }
    
    func removeDocument(sender:UIGestureRecognizer!) {
        NSLog("removing document")
        
        let row = self.formViewController!.form.rowByTag("documents") as! DocumentsRow
        row.removeDocumentView(sender.view!.tag)
    }
        
    func showImageFullScreen(image: UIImage, showAddButton: Bool) {
        let captureImageView: UIImageView = UIImageView(image: image)
        captureImageView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        captureImageView.frame = CGRectOffset(self.view.bounds, 0, -self.view.bounds.size.height)
        captureImageView.alpha = 1.0
        captureImageView.contentMode = .ScaleAspectFit
        captureImageView.userInteractionEnabled = true
        
        if(showAddButton) {
            let addDocumentButton: UIButton = UIButton(frame: CGRectMake(captureImageView.frame.width / 2 - 75, captureImageView.frame.height - 200, 150, 150))
            addDocumentButton.addTarget(self, action: "savePage", forControlEvents: .TouchUpInside)
            addDocumentButton.setImage(UIImage(named: "document_add_button"), forState: .Normal)
            captureImageView.addSubview(addDocumentButton)
        }

//        let closeDocumentButton: UIButton = UIButton(frame: CGRectMake(30 , 30, 50, 50))
//        closeDocumentButton.addTarget(self, action: "dismissPreview:", forControlEvents: .TouchUpInside)
//        closeDocumentButton.setImage(UIImage(named: "close_white"), forState: .Normal)
//        captureImageView.addSubview(closeDocumentButton)
        
        self.view.addSubview(captureImageView)
        
        let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissPreview:")
        captureImageView.addGestureRecognizer(dismissTap)
        
        self.currentPreview = captureImageView
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .AllowUserInteraction, animations: {() -> Void in
            captureImageView.frame = self.view.bounds
            }, completion: nil)
        
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
        self.dismissPreview(self.currentPreview!)
        
        self.selectedImages.append(self.currentImage)
        self.addImagePreview(self.currentImage!, index: (self.selectedImages.count - 1))
    }
}
