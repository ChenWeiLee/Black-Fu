//
//  NewListViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/12/29.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit
import Alamofire

class NewListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var newsTableView: UITableView!
    
    var news:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = "新聞"
        
        self.getNewsData()
        
        print("\(newsTableView.frame.origin.y)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return news.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NewCell") as? NewCell
        let dataDic:NSDictionary = news[indexPath.row] as! NSDictionary
        
        
        cell?.newsTitle.text = dataDic["Title"] as? String
        cell?.newsTime.text = dataDic["Time"] as? String
        
        cell!.newsImage.sd_setImageWithURL(NSURL(string: dataDic["imageURL"]! as! String), placeholderImage: UIImage(named: "icon 6.png"))

        
        return cell ?? UITableViewCell(style: .Default, reuseIdentifier: "CELL")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("NewsWebSegue", sender: (news[indexPath.row] as! NSDictionary)["web"])
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "NewsWebSegue") {
            let newsWebViewController:NewsWebViewController = segue.destinationViewController as! NewsWebViewController
            newsWebViewController.loadWebString = sender as! String
        }
    }
    
    // MARK: - Get News Infornation
    
    func getNewsData() {
        Alamofire.request(.GET, "https://dl.dropboxusercontent.com/u/52019782/BlackFuNew.json")
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    self.news = JSON["News"] as! NSArray
                    
                    self.newsTableView.reloadData()
                }
        }
    }
    
}


class NewCell: UITableViewCell {
    
    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var newsTime: UILabel!
    @IBOutlet var newsTitle: UILabel!
    
    var showFlag:Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        self.showFlag = true
    }
    
    func show() {
        
        if showFlag == false {
            
            let queue:dispatch_queue_t = dispatch_queue_create("zenny_chen_firstQueue", nil);
            
            dispatch_async(queue) { () -> Void in
                guard let stringCount:Int = self.newsTitle.text?.characters.count else{
                    return
                }
                
                if stringCount > 15 {
                    
                    self.newsTitle.text? = "\(self.newsTitle.text!)   "
                    
                    repeat {
                        
                        print("\(self.newsTitle.text!)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.newsTitle.text = "\((self.newsTitle.text! as NSString).substringWithRange(NSMakeRange(1, stringCount+2)))\((self.newsTitle.text! as NSString).substringWithRange(NSMakeRange(0,1)))"
                        })
                        
                        usleep(500000)
                    }while(self.showFlag == false)
                    
                }
                
            }

        }
        
    }
}
