//
//  ViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/11/30.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    
    var tableAry:[String] = ["林鳳營","統一布丁","林老師","大醇豆","36法郎","每日C-柳橙","每日C-葡萄"]
    var tableShowAry:[String] = []
    //MARK: - ViewController 生命週期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableShowAry = tableAry
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Event
    
    @IBAction func scanBarcode(sender: AnyObject) {
        let scanViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Scan") as! ScanViewController
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }
    
    // MARK: - UISearchBar Delegate

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        tableShowAry.removeAll()
        
        if searchText == "" {
            tableShowAry = tableAry
        }else{
            for tableString:String in tableAry {
                if tableString.rangeOfString(searchText) != nil {
                    tableShowAry.append(tableString)
                }
            }
        }

        tableView.reloadData()
        
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return tableShowAry.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = tableShowAry[indexPath.row]
        
        return cell
    }
}

