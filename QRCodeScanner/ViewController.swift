//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Meenakshi Pathani on 3/27/15.
//  Copyright (c) 2015 Mindfire. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var _isScanning: Bool! = false
    var _captureSession: AVCaptureSession?
    var _videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonAction(sender: UIButton) {
        
       _isScanning! ? stopScanning() : startScanning()
        
        _isScanning = !_isScanning

    }

    func startScanning(){
        
        var captureDevice: AVCaptureDevice?
        var input: AVCaptureDeviceInput?
        
        var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if (videoDevices.count > 0)
        {
            var error: NSError?
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            input = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as? AVCaptureDeviceInput
            
            _captureSession = AVCaptureSession()
            _captureSession?.addInput(input)
            
            var captureMetaDataOutput = AVCaptureMetadataOutput()
            _captureSession?.addOutput(captureMetaDataOutput)
            
            var dispatchQueue = dispatch_queue_create("QRCodeScanQueue", nil)
            captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
            
            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
            _videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
            _videoPreviewLayer?.frame = cameraPreview.layer.bounds
            
            cameraPreview.layer.addSublayer(_videoPreviewLayer?)
            
            _captureSession?.startRunning()

            button.setTitle("Stop Scan", forState: UIControlState.Normal)
            label.text = "Scanning for QR Code:-----"
            
        }
        else
        {
            println("Camera is not supported here");
            
            var alertView = UIAlertView(title: "Alert", message: "Current device does not supporting camera ", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    func stopScanning(){
        
        _captureSession?.stopRunning()
        _captureSession = nil
        
        _videoPreviewLayer?.removeFromSuperlayer()
        
        
        button.setTitle("Start Scan", forState: UIControlState.Normal)
        label.text = "QR Code Scan is not started"
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate method
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        if metadataObjects?.count > 0
        {
            var metaDataObj = metadataObjects?.first as AVMetadataMachineReadableCodeObject
            
            if metaDataObj.type == AVMetadataObjectTypeQRCode
            {
                dispatch_async(dispatch_get_main_queue(), {
                    //Run UI Updates
                    
                    self.stopScanning()
                    self._isScanning = false
                    
                    self.button.setTitle("Start Scan", forState: UIControlState.Normal)
                    self.label.text = metaDataObj.stringValue
                    
                    });
            }
        }
    }
    
    
}

