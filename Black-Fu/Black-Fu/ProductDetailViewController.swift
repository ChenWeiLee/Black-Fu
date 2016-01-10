//
//  ProductDetailViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/12/22.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
 
    var navigationTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = navigationTitle ?? "商品"
    }
    
}