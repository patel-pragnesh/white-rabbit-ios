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
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default
//        )

        
        super.viewDidLoad()

        self.setUpNavigationBar()
//        self.setUpNavigationBar((entryObject?["name"] as? String)!)
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem("share_white", action: "showShareActionSheet", height: 40, width: 25)

//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
//        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem = self.getNavBarItem("back_white", action: "goBack", height: 25, width: 25)
//
//        self.navigationItem.backBarButtonItem = self.getNavBarItem("back_black", action: "showEditAminalView", height: 30, width: 20)

        
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
        
        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
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
