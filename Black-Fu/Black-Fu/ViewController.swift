//
//  ViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/11/30.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchCancelBtn: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var scanButton: UIButton!
    
    var longTouching:Bool = false
    var longCell:ProductionCollectionCell = ProductionCollectionCell()
    
    var tableShowAry:[Dictionary<String, String>] = [Dictionary<String, String>]()
    var imageDic:[String:UIImage] = [String:UIImage]()

    lazy var lasyProducts:[String:AnyObject] = {
        
        do {
            
            let productPath:String = NSBundle.mainBundle().pathForResource("Products", ofType: "json")!
            let jsonData:NSData = NSData(contentsOfFile: productPath)!
            let anyObj:AnyObject? = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            print("\(anyObj)")
            return anyObj as! [String : AnyObject]

        } catch let error as NSError {
            print("json error: \(error.localizedDescription)")
            return [String:AnyObject]()
        }
    }()
    
    //MARK: - ViewController 生命週期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableShowAry = lasyProducts["Product"] as! Array


        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        searchCancelBtn.addTarget(self, action: "cancelSearchBtn", forControlEvents: .TouchUpInside)
        
        
        scanButton.layer.masksToBounds = true
        scanButton.layer.cornerRadius = scanButton.frame.width/2
        
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
        tempEffectView.frame = self.view.bounds
        tempEffectView.alpha = 0.9
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
            tableShowAry = lasyProducts["Product"] as! Array
        }else{
            for tableString:Dictionary<String, String> in lasyProducts["Product"] as! Array {
                if tableString["Title"]!.rangeOfString(searchText) != nil {
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
        
//        self.getCollectionImage(tableShowAry[indexPath.row]["ImageURL"]! as String, cell: cell)
        
        
        cell.image.sd_setImageWithURL(NSURL(string: tableShowAry[indexPath.row]["ImageURL"]! as String), placeholderImage: UIImage(named: "icon 6.png"))
        cell.productName.text = tableShowAry[indexPath.row]["Title"]
        cell.company = tableShowAry[indexPath.row]["Company"] as String!
        cell.tag = indexPath.row
        cell.superController = self
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let productDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProductDetail") as! ProductDetailViewController
        
        productDetailViewController.navigationTitle = tableShowAry[indexPath.row]["Title"]
        
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }
    
    // MARK: - Image Catch
    
    func getCollectionImage(imageUrl:String?, cell:ProductionCollectionCell) {
        
        cell.image.image = UIImage(named: "IMG_3253.JPG")

        guard let imageUrlString = imageUrl else {
            return
        }
        
        let imagedic = imageDic[imageUrlString]
        
        if imagedic != nil {
            cell.image.image = imagedic
        }else{
            print(" Image Url: \(imageUrl!)")
            
            Alamofire.request(.GET, "\(imageUrl!)")
                .response { request, response, data, error in
                    
                    if error == nil {
                        let image = UIImage(data: data! as NSData)
                        self.imageDic[imageUrlString] = image
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.image.image = image
                        })
                        
                    }
                    
            }
        }
        
    }

}



class ProductionCollectionCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var productName: UILabel!
    var superController:UIViewController?
    var company:String = ""
    
    var startPoint:CGPoint = CGPoint()
    var isAddEvent:Bool = false
    var isMoveOut:Bool = true
    var productView:ProductDetailView = ProductDetailView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width-40, height: UIScreen.mainScreen().bounds.size.height/2))
    
    func show(point:CGPoint) {
        
        productView.productTitle.text = productName.text
        productView.productImage.image = image.image
        productView.productBrand.text = company
        productView.bringSubviewToFront((superController?.view)!)
        
        
        productView.frame = calculateAnimateFrame(point)
        superController?.view.addSubview(productView)

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.productView.frame = self.calculateDirection(point)
                
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
        
        self.backgroundColor = UIColor(red: 0.49, green: 0.87, blue: 0.83, alpha: 1.0)
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
        productBrand.textColor = UIColor.redColor()
        productBrand.font = UIFont.boldSystemFontOfSize(17.0)
        self.addSubview(productBrand)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

