//
//  NewsWebViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2016/1/8.
//  Copyright © 2016年 TWML. All rights reserved.
//

import UIKit

class NewsWebViewController: UIViewController,UIWebViewDelegate {
    
    
    @IBOutlet var newsWebView: UIWebView!
    
    var loadWebString:String = String()
    
    var loadingActivity:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingActivity.center = newsWebView.center
        self.view.addSubview(loadingActivity)
        
        guard let requestURL = NSURL(string:loadWebString) else {
            return
        }
        
        let request = NSURLRequest(URL: requestURL)
        newsWebView.loadRequest(request)
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadingActivity.startAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        loadingActivity.stopAnimating()
        print("\(error)")
    }

    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingActivity.stopAnimating()
    }
    
}


