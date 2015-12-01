//
//  TodayViewController.swift
//  Fast-Search
//
//  Created by Li Chen wei on 2015/12/1.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    
    @IBOutlet var scanBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        scanBtn.addTarget(self, action: "openAppToScan", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    //MARK: - Enter Start SearchBar

    func openAppToScan() {
        
        self.extensionContext?.openURL(NSURL(string: "BlackFu://")!, completionHandler: nil)
        
        print("Open Url")
        
    }
   
    
}
