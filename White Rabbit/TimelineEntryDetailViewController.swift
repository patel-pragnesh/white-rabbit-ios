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
    
    var entryObject : PFObject?
    
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
