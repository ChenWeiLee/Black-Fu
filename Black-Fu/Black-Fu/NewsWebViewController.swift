//
//  NewsWebViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2016/1/8.
//  Copyright © 2016年 TWML. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NewsWebViewController: UIViewController,UIWebViewDelegate {
    
    
    @IBOutlet var newsWebView: UIWebView!
    
    var loadWebString:String = String()
    
    var loadingActivity:NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .BallClipRotatePulse, color: UIColor(red: 0.49, green: 0.87, blue: 0.47, alpha: 1.0), size: CGSizeMake(100, 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        loadingActivity.center = self.view.center
        self.view.addSubview(loadingActivity)
        
        guard let requestURL = NSURL(string:loadWebString) else {
            return
        }
        
        let request = NSURLRequest(URL: requestURL)
        newsWebView.loadRequest(request)
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadingActivity.startAnimation()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        loadingActivity.stopAnimation()
        print("\(error)")
    }

    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingActivity.stopAnimation()
    }
    
}


