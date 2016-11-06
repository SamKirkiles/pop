//
//  RequestAccessToPhotosViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/23/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Photos
import Messages

let RequestAccessSegueID = "RequestAccessID"

protocol RequestAccessDelegate{
    func photosAuthorized()
    func isCameraType() -> Bool
}

class RequestAccessToPhotosViewController: UIViewController, TransitionDelegate {
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    var delegate:RequestAccessDelegate? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .expanded{
            stackViewTopConstraint.constant = 80
        }else{            
            stackViewTopConstraint.constant = -10
                
        }
    }
    
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        @IBAction func tapRecognized(_ sender: AnyObject) {
            guard let delegate = self.delegate else{
                fatalError("delegate was nil on RequestAccessController")
            }
            
            if delegate.isCameraType() == true{
                if (AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized){
                    self.dismiss(animated: true, completion: {
                        delegate.photosAuthorized()
                    })
                }
            }else{
                if PHPhotoLibrary.authorizationStatus() == .authorized{
                    self.dismiss(animated: true, completion: {
                        delegate.photosAuthorized()
                    })
                }
            }
        }
        
}
