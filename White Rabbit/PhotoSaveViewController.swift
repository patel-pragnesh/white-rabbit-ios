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

public class DocumentCell: Cell<Set<PFObject>>, CellType {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var documentsStackView: UIStackView!
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
    }
    
    public override func setup() {
        height = { 120 }
        row.title = nil
        super.setup()
        selectionStyle = .None
//        for subview in contentView.subviews {
//            if let button = subview as? UIButton {
//                button.setImage(UIImage(named: "checkedDay"), forState: UIControlState.Selected)
//                button.setImage(UIImage(named: "uncheckedDay"), forState: UIControlState.Normal)
//                button.adjustsImageWhenHighlighted = false
//            }
//        }
    }
}

public final class DocumentsRow: Row<Set<PFObject>, DocumentCell>, RowType {
    var documents: [PFObject!] = [PFObject!]()
    var documentViews: [UIButton!] = [UIButton!]()
    
    public func addDocumentView(imageView: UIButton) {
        let cell = self.cell as DocumentCell
        cell.documentsStackView.addSubview(imageView)
        self.documentViews.append(imageView)
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<DocumentCell>(nibName: "DocumentCell")
    }
}

class PhotoSaveViewController: FormViewController {
    var animalDetailController : AnimalDetailViewController?
    
    var image : UIImage?
    var animalObject : PFObject?
    var pickedImageDate : NSDate?
    
    var type : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(type == "medical") {
            self.setUpNavigationBar("Medical Entry")
            self.generateMedicalForm()
        } else {
            self.setUpNavigationBar("Photo Entry")
            self.generateForm()
        }
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("close_white", action: "closeView", height: 25, width: 25)
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
                $0.placeholder = "Enter caption here..."
                }.cellSetup { cell, row in
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
            <<< PushRow<String>("text") {
                $0.title = "Type"
                $0.options = ["Vet Visit", "Vaccine", "Spay/Neuter", "Document"]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_medical_type")
                }
            <<< PushRow<String>("location") {
                $0.title = "Location"
                $0.options = ["Vet Visit", "Vaccine", "Spay/Neuter", "Document"]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_location")
                }
            <<< TextAreaRow("details") {
                $0.title = "Details"
                $0.placeholder = "Enter details here..."
                }.cellSetup { cell, row in
                }
            <<< DocumentsRow("documents") {
                    $0.title = "Documents"
                }.onCellSelection { cell, row in
//                    let cell = cell as! DocumentCell
//                    self.showAddDocumentView()
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_documents")
                    cell.addButton.addTarget(self, action: "showAddDocumentView", forControlEvents: UIControlEvents.TouchUpInside)
                }

    }
    
    func showAddDocumentView() {
        let docView: DocumentCaptureViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DocumentCapture") as! DocumentCaptureViewController
        docView.formViewController = self
        self.presentViewController(docView, animated: true, completion: { () -> Void in
        })
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
        if self.type != "" {
            timelineEntry["type"] = self.type
        } else {
            timelineEntry["type"] = "image"
        }
        
        
        self.showLoader()
        timelineEntry.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.hideLoader()
            if(success) {
                NSLog("finished saving post")
                
                NSLog("saved post: " + timelineEntry.objectId!)
                
                let documentsRow = self.form.rowByTag("documents") as? DocumentsRow
                documentsRow?.documents.forEach({ (element) -> Void in
                    let document = element
                    document["entry"] = timelineEntry
                    document.saveInBackground()
                })
                
                self.closeView()
            } else {
                NSLog("error uploading file: \(error?.localizedDescription)")
                self.view.dodo.error((error?.localizedDescription)!)
                self.closeView()
            }
        }
    }

    func closeView() {
        if (self.animalDetailController != nil) {
            self.dismissViewControllerAnimated(true) { () -> Void in
                self.animalDetailController!.reloadTimeline()
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
