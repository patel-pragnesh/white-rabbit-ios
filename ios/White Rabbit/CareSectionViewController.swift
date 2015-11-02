//
//  CareSectionViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/22/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import UIKit
import ContentfulDeliveryAPI
import MMMarkdown

//class CareSectionViewController: CDAEntriesViewController {
class CareSectionViewController: UIViewController {

    @IBOutlet weak var webContent: UIWebView!
    
    var contentId : String = ""
    var headerName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBarImage(UIImage(named: self.headerName)!, height: 88)
        
        self.displayContent()
    }
    
    func displayContent() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.client?.fetchEntryWithIdentifier(self.contentId, success: { (response: CDAResponse, entry: CDAEntry) -> Void in
            NSLog("entry: \(entry)")
            
            let fields = entry.valueForKey("fields")!
            let content = fields.valueForKey("content") as! String
            
            // let title = fields.valueForKey("title") as! String
            // self.navigationItem.title = title
                        
            var html : String!
            do {
                html = try MMMarkdown.HTMLStringWithMarkdown(content)
            } catch _ {
                print("Something went wrong converting markdown!")
            }
            let htmlString = NSString(format: "<html><body style=\"font-family:'Avenir'; padding: 10px; padding-top: 50px; padding-bottom: 80px;\">%@</body></html>", html).stringByReplacingOccurrencesOfString("//", withString: "https://") as String
            NSLog("html: \(htmlString)")
            self.webContent.loadHTMLString(htmlString, baseURL: nil)
            }, failure: { (response: CDAResponse?, error: NSError) -> Void in
                NSLog("error getting entry: \(error)")
        })
    }
}
