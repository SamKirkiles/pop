//
//  CameraViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/17/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages
import AVFoundation

let CameraVCStoryboardID = "CameraVC"

protocol CameraDelegate{
    func didChooseImage(image:UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, TransitionDelegate, RequestAccessDelegate {
    
    
    var transitionDelegate: TransitionDelegate? = nil
    
    
    // AVFoundation Properties
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCapturePhotoOutput?
    
    //IBOutlets
    @IBOutlet weak var stillImageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var snapPhotoButton: UIButton!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    //Delegates
    var delegate:CameraDelegate? = nil
    
    var outputImage:UIImage?
    
    var authoirzationPresented = false
    
    override func viewDidAppear(_ animated: Bool) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized{
            if authoirzationPresented == false{
                self.performSegue(withIdentifier: RequestAccessSegueID, sender: self)
                authoirzationPresented = true
            }
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(granted) in
                if granted == true{
                    self.setupCamera()
                }
            })
            
        }
    }
    
    override func viewDidLoad() {
        self.stillImageView.isHidden = true
        self.closeButton.isHidden = true
        self.snapPhotoButton.isHidden = false
        self.saveButton.isHidden = true
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized{
            self.setupCamera()
        }
    }
    
    func setupCamera(){
        captureSession = AVCaptureSession()
        //create the input device for the capture session
        
        let deviceInput:AVCaptureDeviceInput
        do{
            deviceInput = try AVCaptureDeviceInput(device: AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo))
            
        }catch {
            fatalError(error.localizedDescription)
        }
        
        captureSession?.addInput(deviceInput)
        
        stillImageOutput = AVCapturePhotoOutput()
        
        self.captureSession?.addOutput(stillImageOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer?.frame = self.view.bounds
        self.view.layer.insertSublayer(previewLayer!, below: stillImageView.layer)
        
        self.captureSession?.startRunning()
        let connection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo)
        
        
        
        if (connection) != nil{
            connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        }else{
            fatalError("it was nil")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RequestAccessSegueID{
            let requestController = segue.destination as! RequestAccessToPhotosViewController
            self.transitionDelegate = requestController
            requestController.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            var image = UIImage(data: photoData!, scale: 1.0)
            stillImageView.image = image
            
            image = image?.fixOrientation()
            self.outputImage = image
            
            snapPhotoButton.isHidden = true
            closeButton.isHidden = false
            stillImageView.isHidden = false
            choosePhotoButton.isHidden = false
            saveButton.isHidden = false
            
            
            
        }
        else {
            return
        }
        
    }
    
    //MARK: IBActions
    @IBAction func snapPhotoPressed(_ sender: AnyObject) {
        
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            
            let settings = AVCapturePhotoSettings()
            
            stillImageOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    @IBAction func choosePhotoButtonPressed(_ sender: AnyObject) {
        
        guard let delegate = self.delegate else{
            fatalError("Delegate on Camera view controller was nil")
        }
        if let image = self.outputImage{
            delegate.didChooseImage(image: image)
            self.dismiss(animated: true, completion: nil)
        }else{
            fatalError("Could not continue because image was nil")
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        stillImageView.isHidden = true
        closeButton.isHidden = true
        snapPhotoButton.isHidden = false
        choosePhotoButton.isHidden = true
        saveButton.isHidden = true
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Save to camera roll?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in

        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let image = self.outputImage else{
                fatalError("output image was nil")
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        
        if let delegate = self.transitionDelegate{
            delegate.didTransition(presentationStyle: presentationStyle)
        }else{
        }
        
        if presentationStyle == .expanded{
            closeButtonTopConstraint.constant = 80
            
        }else{
            closeButtonTopConstraint.constant = 0
            if self.presentedViewController == nil{
                self.dismiss(animated: true, completion: {
                    
                })
            }else{
                self.presentedViewController?.dismiss(animated: false, completion: {
                    self.dismiss(animated: false, completion: nil)
                    
                })
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.view.frame.size.height > self.view.frame.size.width {
            //we are now in landscape
            self.performSegue(withIdentifier: CoverVCSegue, sender: self)
        } else {    // in landscape
            // we are now in portrait
        }
    }
    
    func photosAuthorized() {
        self.setupCamera()
    }
    
    func isCameraType() -> Bool {
        return true
    }
    
}

extension UIImage{
    func fixOrientation() -> UIImage {
        
        if (self.imageOrientation == UIImageOrientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
}
