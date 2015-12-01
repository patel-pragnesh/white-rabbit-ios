//
//  TimelineEntryDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit

class TimelineEntryDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var documentsView: UIView!
    
    var entryObject : PFObject?
    
    var documents : [[UIImage!]] = [[UIImage!]]()
    
    let previewPadding = 20
    let previewWidth = 125
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBar()
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("share_white", action: "showShareActionSheet", height: 40, width: 30)
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
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
        
        if(entryObject?.objectForKey("hasDocuments") != nil && entryObject?.objectForKey("hasDocuments") as! Bool) {

            let documentQuery = PFQuery(className: "Document")
            documentQuery.whereKey("entry", equalTo: entryObject!)

            documentQuery.findObjectsInBackgroundWithBlock({ (documents: [PFObject]?, error: NSError?) -> Void in
                if(error == nil) {
                    documents?.forEach({ (element: PFObject) -> Void in
                        let document = PFObject(withoutDataWithClassName: "Document", objectId: element.objectId)
                        
                        let index = self.documents.count
                        self.documents.append([UIImage!]())
                        
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
                                            
                                            self.documents[index].append(image)
                                            self.updateDocumentsView()
                                        }
                                    })
                                })
                                
                            }
                        })
                    })
                } else {
                    self.view.dodo.error((error?.localizedDescription)!)
                }
            })
        
        }
    }
    
    func updateDocumentsView() {
        for view in documentsView.subviews{
            view.removeFromSuperview()
        }
        var index = 0
        self.documents.forEach { (document) -> Void in
            if document.count > 0 {
                self.addDocumentView(document[0], index: index)
                index++
            }
        }
    }
    
    func addDocumentView(image: UIImage, index: Int) {
//        let index = self.documents.count - 1
        let minX = ((index * self.previewWidth) + ((index + 1) * (self.previewPadding / 2)))
        let minY = self.previewPadding / 2
        let height = self.documentsView.frame.height - CGFloat(self.previewPadding)
        
        let imageView: UIButton = UIButton(frame: CGRectMake(CGFloat(minX), CGFloat(minY), CGFloat(self.previewWidth), CGFloat(height)))
        imageView.setImage(image, forState: .Normal)

        imageView.addTarget(self, action: "showFullScreen:", forControlEvents: .TouchUpInside)
        
        self.documentsView.addSubview(imageView)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.goBack()
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func showShareActionSheet() {
        let image = self.imageView.image
        let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image!], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
