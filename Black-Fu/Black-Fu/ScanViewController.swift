//
//  ScanViewController.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/12/2.
//  Copyright © 2015年 TWML. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI

class ScanViewController: UIViewController ,ResultDelegate ,MFMailComposeViewControllerDelegate ,AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet var scanView: UIView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var reportBtn: UIButton!
    
    var resoultFailView:resoultAdd?
    
    
    var captureSession:AVCaptureSession?
    var captureStillImageOutput:AVCaptureStillImageOutput? //Image串流
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var scanViewBack = UIButton(type: UIButtonType.Custom)
    
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeQRCode]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        resoultFailView = resoultAdd(frame:CGRect(x: 0, y: 0, width:self.view.frame.width*2/3 , height: self.view.frame.height*2/3))
        resoultFailView?.delegate = self
        
        nextButton.addTarget(self, action: "nextScan", forControlEvents: UIControlEvents.TouchUpInside)
        backBtn.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nextButton.enabled = false
        self.scanBarCode()
    }
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = scanView.frame
    }
    override func viewDidDisappear(animated: Bool) {
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Button Event
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func nextScan() {
        captureSession?.startRunning()
        qrCodeFrameView?.frame = CGRectZero
        nextButton.enabled = false
    }
    
    func resoultValue(scanString:String) {
        
        self.snapshot()
        
        self.view.addSubview(resoultFailView!);
        resoultFailView?.reportProductName.becomeFirstResponder()
    }
    
    func snapshot() {
        
        let captureConnection :AVCaptureConnection = (captureStillImageOutput?.connectionWithMediaType(AVMediaTypeVideo))!
        
        
        captureStillImageOutput?.captureStillImageAsynchronouslyFromConnection(captureConnection){
            (imageSampleBuffer : CMSampleBuffer!, _) in
            
            let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            self.resoultFailView?.imagesnapshot.image = UIImage(data: imageDataJpeg)!
        }
        
    }
    
    // MARK: - Result Delegate

    func cancelReportEnter() {
        resoultFailView?.removeFromSuperview()
        self.nextScan()
    }
    
    func reportEnter(mailController: MFMailComposeViewController) {
        
        mailController.mailComposeDelegate = self
        self.presentViewController(mailController, animated: true, completion: nil)
        resoultFailView?.removeFromSuperview()
        
    }
    
    // MARK: - BarCode Method

    func scanBarCode(){
        
        do {
            
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureStillImageOutput = AVCaptureStillImageOutput()
            captureStillImageOutput?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            captureSession?.addOutput(captureStillImageOutput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = scanView.frame
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            
            

            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            let alert = UIAlertController(title: "Error", message: "Can't open", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print(error)
            return
        }
        
    }
    
    //MARK: - AVCaptureMetadataOutputObjects Delegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            print("No barcode/QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                print(metadataObj.stringValue)
                nextButton.enabled = true
                self.resoultValue(metadataObj.stringValue)
                
                captureSession?.stopRunning()
                
                captureOutput.connectionWithMediaType(AVMediaTypeVideo)
                
                
            }
        }

    }
    
    // MARK: - MFMailComposeViewController Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}


public protocol ResultDelegate: NSObjectProtocol {
    
    func cancelReportEnter()
    func reportEnter(mailController:MFMailComposeViewController)
    // 協定內容
}

class resoultAdd: UIView , UITextFieldDelegate {
    var delegate: ResultDelegate?
    
    var reportView = UIView()
    var reportTitle = UILabel()
    var reportProductName = UITextField()
    var imagesnapshot:UIImageView = UIImageView()
    
    var cancelReportBtn = UIButton(type: .Custom)
    var reportBtn = UIButton(type: .Custom)
    

    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height))
        self.addSubview(lasyEffectView)
        
        
        reportView.frame = frame
        reportView.backgroundColor = UIColor.whiteColor()
        reportView.layer.masksToBounds = true
        reportView.layer.cornerRadius = 15.0
        reportView.center = self.center
        
        
        reportTitle.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 44)
        reportTitle.textAlignment = .Center
        reportTitle.text = "回報系統"
        reportView.addSubview(reportTitle)
        
        reportProductName.frame = CGRect(x: 0, y: reportTitle.frame.height, width: frame.size.width, height: 44)
        reportProductName.placeholder = "回報商品名稱"
        reportProductName.delegate = self
        reportProductName.returnKeyType = .Done
        reportProductName.textAlignment = .Center
        reportView.addSubview(reportProductName)
        
        imagesnapshot.frame = CGRect(x:(frame.width - (frame.height - 150)*3/4) / 2 , y: reportProductName.frame.height + reportProductName.frame.origin.y+5, width: (frame.height - 150)*3/4, height: frame.height - 150)
        reportView.addSubview(imagesnapshot)
        
        cancelReportBtn.frame = CGRect(x: 0, y: frame.size.height - 44, width: frame.size.width/2, height: 44)
        cancelReportBtn.setTitle("取消", forState: .Normal)
        cancelReportBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        cancelReportBtn.addTarget(self, action: "enterCancel", forControlEvents: .TouchUpInside)
        reportView.addSubview(cancelReportBtn)
        
        reportBtn.frame = CGRect(x: frame.size.width/2, y: frame.size.height - 44, width: frame.size.width/2, height: 44)
        reportBtn.setTitle("回報", forState: .Normal)
        reportBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        reportBtn.addTarget(self, action: "enterReport", forControlEvents: .TouchUpInside)
        reportView.addSubview(reportBtn)
        
        
        self.addSubview(reportView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func enterCancel() {
        delegate?.cancelReportEnter()
    }
    
    // MARK: - Result Button Event
    
    func enterReport() {
        let mailComposerVC = MFMailComposeViewController()

        mailComposerVC.setToRecipients(["blackheartfu@gmail.com"])
        mailComposerVC.setSubject("回報有問題的商品")
        mailComposerVC.setMessageBody("此商品『\(reportProductName.text ?? "")』未在此“黑心富”App找到，但它是有問題商品。", isHTML: false)
        mailComposerVC.addAttachmentData(UIImagePNGRepresentation(imagesnapshot.image!)!, mimeType: "image/png", fileName: "reportImage")
        
        delegate?.reportEnter(mailComposerVC)
    }
    
    // MARK: - 毛玻璃
    
    lazy var lasyEffectView:UIVisualEffectView = {
        // iOS8 系统才有
        let tempEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        tempEffectView.frame = self.bounds;
        tempEffectView.alpha = 0.8
        tempEffectView.userInteractionEnabled = true
        return tempEffectView
    }()
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}

class resoult: UIView {
    
}


