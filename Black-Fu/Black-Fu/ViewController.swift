//
//  ViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/11/30.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchCancelBtn: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    
    var longTouching:Bool = false
    var longCell:ProductionCollectionCell = ProductionCollectionCell()
    
    var tableAry:[String] = ["林鳳營鮮乳","統一布丁","大醇豆","36法郎","每日C-柳橙","每日C-葡萄","VOSSI加拿大冰河水","康師傅","大絕韻瓶裝茶","木崗高品質雞蛋","自然果力果汁","貝納頌咖啡","ABLS優酪乳","味全天然水","味全雞蛋布丁","醇奶布丁系列","味全果汁","廚易料理醬","味全高鮮調味料","味全調味乳","台灣搵醬","味全烤肉醬","味全水餃醬汁","味全甘醇油膏","味全香菇素蠔油","味全優格","鮮Soup","味全鮮乳","林鳳營優酪乳","味全醬油","味全嚴選調味乳","原榨果汁","健康廚房沾拌淋醬","健康廚房調味料","涼爽茶","淬釀醬油","荷頓奶粉","Apas礦質水","LCA506發酵乳"]
    var tableShowAry:[String] = []
    var imageDic:[String:UIImage] = [String:UIImage]()

    
    
    //MARK: - ViewController 生命週期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableShowAry = tableAry
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        searchCancelBtn.addTarget(self, action: "cancelSearchBtn", forControlEvents: .TouchUpInside)
        
        
        let gesture = UILongPressGestureRecognizer(target: self, action: "longTouchEvent:")
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(gesture)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        searchCancelBtn.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Detail View & 毛玻璃
    
    func longTouchEvent(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            print("Ended")
            longTouching = false
            longCell.cancel()
            lasyEffectView.removeFromSuperview()
            return
        }else if longTouching == false{
            longTouching = true
            
            let pointCollection:CGPoint = gestureRecognizer.locationInView(collectionView)
            let pointScreen:CGPoint = gestureRecognizer.locationInView(self.view)
            
            let indexPath = collectionView.indexPathForItemAtPoint(pointCollection)
            if indexPath != nil {
                longCell = collectionView.cellForItemAtIndexPath(indexPath!) as! ProductionCollectionCell
                self.view.addSubview(lasyEffectView)
                longCell.show(pointScreen)
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
    lazy var lasyEffectView:UIVisualEffectView = {
        // iOS8 系统才有
        let tempEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        tempEffectView.frame = self.view.bounds;
        tempEffectView.alpha = 0.8
        tempEffectView.userInteractionEnabled = true
        return tempEffectView
    }()
    
    // MARK: - Button Event
    
    @IBAction func scanBarcode(sender: AnyObject) {
        let scanViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Scan") as! ScanViewController
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }
    
    @IBAction func moreNewList(sender: UIButton) {
        
        
    }
    
    func cancelSearchBtn(){
        
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        searchCancelBtn.enabled = false
    }
    
    
    // MARK: - UISearchBar Delegate

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool{
        
        searchCancelBtn.enabled = true

        return true
    }
    
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

        collectionView.reloadData()
        
    }

    
    // MARK: - UICollectionView Delegate & DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return tableShowAry.count;
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionCell", forIndexPath: indexPath) as! ProductionCollectionCell
        
        cell.image.image = UIImage(named: "IMG_3253.JPG")
        cell.productName.text = tableShowAry[indexPath.row]
        cell.tag = indexPath.row
        cell.superController = self
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let productDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProductDetail") as! ProductDetailViewController
        
        productDetailViewController.navigationTitle = tableShowAry[indexPath.row]
        
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }

}



class ProductionCollectionCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var productName: UILabel!
    var superController:UIViewController?
    
    var startPoint:CGPoint = CGPoint()
    var isAddEvent:Bool = false
    var isMoveOut:Bool = true
    var productView:ProductDetailView = ProductDetailView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width-40, height: UIScreen.mainScreen().bounds.size.height/2))
    
    func show(point:CGPoint) {
        print("\(self.tag)")
        
        productView.productTitle.text = productName.text
        productView.productImage.image = image.image
        
        productView.bringSubviewToFront((superController?.view)!)
        
        
        productView.frame = calculateAnimateFrame(point)
        superController?.view.addSubview(productView)

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.productView.frame = self.calculateDirection(point)
        }, completion: { finished in
                
                
        })
    }
    
    func cancel(){
        productView.removeFromSuperview()
    }
    
    func calculateDirection(point:CGPoint) -> CGRect{
        
        var viewFrame = CGRect()
        
        viewFrame.origin.x = 20
        viewFrame.size.height = UIScreen.mainScreen().bounds.size.height/2
        viewFrame.size.width = UIScreen.mainScreen().bounds.size.width-40
        
        if point.y < UIScreen.mainScreen().bounds.size.height/2 {
            viewFrame.origin.y = point.y
        }else{
            viewFrame.origin.y = point.y - UIScreen.mainScreen().bounds.size.height/2
        }
        
        return viewFrame
    }
    
    func calculateAnimateFrame(originalPoint:CGPoint) -> CGRect{
        
        var viewFrame = CGRect()
        
        viewFrame.size.height = UIScreen.mainScreen().bounds.size.height/4
        viewFrame.size.width = (UIScreen.mainScreen().bounds.size.width-40)/2
        
        
        if originalPoint.x < UIScreen.mainScreen().bounds.size.width/2 {
            viewFrame.origin.x = originalPoint.x
        }else{
            viewFrame.origin.x = originalPoint.x - viewFrame.size.width
        }

        
        if originalPoint.y < UIScreen.mainScreen().bounds.size.height/2 {
            viewFrame.origin.y = originalPoint.y
        }else{
            viewFrame.origin.y = originalPoint.y - viewFrame.size.height
        }
        
        return viewFrame
    }
    
}

class ProductDetailView: UIView {
    
    var productTitle:UILabel = UILabel()
    var productImage:UIImageView = UIImageView()
    var productBrand:UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15.0
        
        
        productTitle.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 45)
        productTitle.textAlignment = .Center
        productTitle.font = UIFont.boldSystemFontOfSize(17.0)
        self.addSubview(productTitle)
        
        
        productImage.frame = CGRect(x:10 , y: productTitle.frame.height + productTitle.frame.origin.y+5, width: frame.height-20, height: frame.height - 100)
        productImage.contentMode = .ScaleAspectFit
        self.addSubview(productImage)
        
        
        productBrand.frame = CGRect(x: 0, y: frame.height - 45, width: frame.size.width, height: 45)
        productBrand.textAlignment = .Center
        productBrand.text = "味全"
        productBrand.textColor = UIColor.redColor()
        productBrand.font = UIFont.boldSystemFontOfSize(17.0)
        self.addSubview(productBrand)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

