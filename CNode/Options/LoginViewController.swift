//
//  LoginViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/10/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import AVFoundation
import UIKit
import PureLayout

class LoginViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    //var qrCodeFrameView:UIView?
    var messageLabel: UILabel!
    var validating = false
    var invalid_codes = [String]()
    
    class func create() -> UIViewController {
        return UINavigationController(rootViewController: LoginViewController())
    }
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = Utils.navButton(0xf00d, target: self, action: "close")
        navigationItem.title = "扫描二维码登录"


        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
            // as the media type parameter.
            let input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        
        let qrFrame = UIImageView(image: UIImage(named: "qr_code_bg.9.png"))
        qrFrame.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(qrFrame)
        qrFrame.autoCenterInSuperview()
        qrFrame.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        
        messageLabel = UILabel()
        messageLabel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        messageLabel.text = "二维码在登录后设置最下方"
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.textAlignment = .Center
        view.addSubview(messageLabel)
        messageLabel.autoSetDimension(ALDimension.Height, toSize: 34)
        messageLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 10)
        messageLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 10)
        messageLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 20)
        Utils.roundUp(messageLabel, radius: 6)
        
        // Start video capture.
        captureSession?.startRunning()
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            //qrCodeFrameView?.frame = CGRectZero
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            //let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            //qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                if !validating {
                    if invalid_codes.contains(metadataObj.stringValue) {
                        self.messageLabel.text = "无效授权码，是否扫错图？"
                        return
                    }
                    validating = true
                    ApiClient(self).validateToken(metadataObj.stringValue,
                        error: { err in
                            self.invalid_codes.append(metadataObj.stringValue)
                            self.messageLabel.text = "无效授权码，是否扫错图？"
                            self.validating = false
                        },
                        success: { data in
                            AppDelegate.app.doLogin(data["loginname"].stringValue, token: metadataObj.stringValue)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    )
                    print(metadataObj.stringValue)
                }
            }
        }
    }
}