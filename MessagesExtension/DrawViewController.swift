//
//  DrawViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages

let DrawViewControllerSegueID = "DrawVCSegueID"
let DrawViewControllerStoryboardID = "DrawViewControllerID"

protocol DrawViewControllerScrollDelegate {
    func zoomChanged(value:CGFloat)
}

protocol SendImageDelegate{
    func sendImage(image:UIImage)
    func requestStyle(style:MSMessagesAppPresentationStyle)
}

protocol PresentationStyleDelegate{
    func getPresentationStyle() -> MSMessagesAppPresentationStyle
}

class DrawViewController: UIViewController, UIScrollViewDelegate, TransitionDelegate, BrushSettingsDelegate, ZoomDelegate {
    
    //Delegates
    var scrollDelegate: DrawViewControllerScrollDelegate? = nil
    var sendImageDelegate:SendImageDelegate? = nil
    var presentationStyleDelegate:PresentationStyleDelegate? = nil
    
    //IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBase: UIView!
    @IBOutlet weak var contentView: ContentView!
    
    @IBOutlet weak var buttonOutline: UIImageView!
    //Constraints
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var sendButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewTopConstraint: NSLayoutConstraint!
    
    var drawVCTransitionDelegate:TransitionDelegate? = nil
    
    //Properties
    var image:UIImage?
    
    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    //Buttons
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    //Misc
    
    var zooming = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        self.scrollView.delaysContentTouches = false
        self.scrollDelegate = self.contentView
        
        self.verifyImage()
        
    }        

    
    
    func verifyImage(){
        if let image = self.image{

            DispatchQueue.main.async {
                self.loadingImageView.isHidden = true
                self.contentView.image = image
                self.contentView.isUserInteractionEnabled = true
                self.contentView.setNeedsDisplay()
            }
            
            guard let delegate = self.presentationStyleDelegate else{
                fatalError("Presenationstyle delegate was nil on drawviewcontroller")
            }
            
            
            if (self.view.frame.width >= self.view.frame.height)
            {
                updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:false)
                self.updateConstraints()
                
            }
            else{
                updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:true)
                self.updateConstraints()
                
            }
        }else{
            self.loadingImageView.rotate()
            self.loadingImageView.isHidden = false
        }
        
    }
    
    //View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.colorPickerButton.tintColor = UIColor(cgColor: self.contentView.drawColor)
        self.progressView.isHidden = true
        self.progressView.transform = CGAffineTransform(scaleX: 1, y: 4)
        
        guard let delegate = self.presentationStyleDelegate else{
            fatalError("Presenationstyle delegate was nil on drawviewcontroller")
        }
        
        if self.view.frame.width >= self.view.frame.height{
            updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:false)
            
        }else{
            updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:true)
            
        }
        
        self.updateButtonVisibility(presentationStyle: delegate.getPresentationStyle())
        
        self.contentView.zoomDelegate = self

    }
    
    override func viewDidLayoutSubviews() {
        guard let delegate = self.presentationStyleDelegate else{
            fatalError("Presenationstyle delegate was nil on drawviewcontroller")
        }
        
        
        if(self.view.frame.width >= self.view.frame.height)
        {
            updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:false)
            self.updateConstraints()
            
        }
        else{
            updateButtonConstraints(presentationStyle: delegate.getPresentationStyle(), portrait:true)
            self.updateConstraints()
            
        }
    }
    
    func updateConstraints(){
        
        DispatchQueue.main.async {
            
            
            guard let image = self.image else {
                return
            }
            
            // if the width is greater than the height
            if image.size.width>image.size.height{
                
                if self.view.frame.height >= self.view.frame.width{
                    if image.size.width/image.size.height > self.scrollView.bounds.width/self.scrollView.bounds.height{
                        self.contentViewRightConstraint.constant = 0
                        self.contentViewLeftConstraint.constant = 0
                        self.contentViewTopConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                        self.contentViewBottomConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                    }else{
                        self.contentViewBottomConstraint.constant = 0
                        self.contentViewTopConstraint.constant = 0
                        self.contentViewRightConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                        self.contentViewLeftConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                        self.contentView.setNeedsDisplay()
                    }
                }else{
                    //WHEN WE ARE IN LANDCAPE WITH A BAD IAMGE
                    self.contentViewTopConstraint.constant = 0
                    self.contentViewBottomConstraint.constant = 0
                    self.contentViewRightConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                    self.contentViewLeftConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                    self.contentView.setNeedsDisplay()
                    
                }
            }else if image.size.width<image.size.height{
                if self.view.frame.height >= self.view.frame.width{
                    if image.size.width/image.size.height > self.scrollView.bounds.width/self.scrollView.bounds.height{
                        self.contentViewRightConstraint.constant = 0
                        self.contentViewLeftConstraint.constant = 0
                        self.contentViewTopConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                        self.contentViewBottomConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                    }else{
                        self.contentViewBottomConstraint.constant = 0
                        self.contentViewTopConstraint.constant = 0
                        self.contentViewRightConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                        self.contentViewLeftConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                        self.contentView.setNeedsDisplay()
                    }
                }else{
                    // WHEN WE ARE IN PORTRAIT WITH A BAD IMAGE MAYBE PUT THIS IN UPDATE 2?
                    self.contentViewBottomConstraint.constant = 0
                    self.contentViewTopConstraint.constant = 0
                    self.contentViewRightConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                    self.contentViewLeftConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                    self.contentView.setNeedsDisplay()
                    
                }
            }else{
                if self.view.frame.height >= self.view.frame.width{
                    self.contentViewTopConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                    self.contentViewBottomConstraint.constant = (self.scrollView.bounds.height - (self.scrollView.bounds.width * image.size.height)/image.size.width)/2
                    self.contentViewRightConstraint.constant = 0
                    self.contentViewLeftConstraint.constant = 0
                    self.contentView.setNeedsDisplay()
                    
                }else{
                    self.contentViewTopConstraint.constant = 0
                    self.contentViewBottomConstraint.constant = 0
                    self.contentViewRightConstraint.constant = ((self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2)
                    self.contentViewLeftConstraint.constant = (self.scrollView.bounds.width - (self.scrollView.bounds.height * image.size.width)/image.size.height)/2
                    
                    self.contentView.setNeedsDisplay()
                    
                    
                }
            }
            let offsetX = max((self.scrollView.bounds.width - self.scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((self.scrollView.bounds.height - self.scrollView.contentSize.height) * 0.5, 0)
            self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
        }
        
        
    }
    
    func updateButtonConstraints(presentationStyle: MSMessagesAppPresentationStyle, portrait: Bool){
        DispatchQueue.main.async {
            
            if presentationStyle == .compact{
                self.closeButtonTopConstraint.constant = 0
                self.sendButtonTopConstraint.constant = 0
                self.scrollViewTopConstraint.constant = 0
                self.progressViewTopConstraint.constant = 0
            }else if portrait == false{
                self.closeButtonTopConstraint.constant = 80
                self.sendButtonTopConstraint.constant = 80
                self.scrollViewTopConstraint.constant = 65
                self.progressViewTopConstraint.constant = 65
            }else{
                self.closeButtonTopConstraint.constant = 80
                self.sendButtonTopConstraint.constant = 80
                self.scrollViewTopConstraint.constant =  86
                self.progressViewTopConstraint.constant = 86

            }
        }
    }
    
    
    func updateButtonVisibility(presentationStyle: MSMessagesAppPresentationStyle){
        if presentationStyle == .compact{
            self.contentView.isUserInteractionEnabled = false
            self.colorPickerButton.isHidden = true
            self.buttonOutline.isHidden = true
            self.undoButton.isHidden = true
            self.editButton.isHidden = false
        }else{
            self.contentView.isUserInteractionEnabled = true
            self.colorPickerButton.isHidden = false
            self.buttonOutline.isHidden = false
            self.undoButton.isHidden = false
            self.editButton.isHidden = true
        }
    }
    

    
    //MARK: UIButtons
    @IBAction func editPressed(_ sender: AnyObject) {
        guard let sendDelegate = self.sendImageDelegate else {
            fatalError("Tried to send image but class did not have a send image delegate")
        }
        sendDelegate.requestStyle(style: .expanded)
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        guard let sendDelegate = self.sendImageDelegate else {
            fatalError("Tried to send image but class did not have a send image delegate")
        }
        
        
        self.dismiss(animated: true, completion: {
            sendDelegate.requestStyle(style: .compact)
        })
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, false, 3.0)
        guard let context = UIGraphicsGetCurrentContext()else{
            fatalError("context was nil!")
        }
        self.contentView.layer.render(in: context)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else{
            fatalError("Tried to create image from current graphics context but it returned nil!")
        }
        
        guard let sendDelegate = self.sendImageDelegate else {
            fatalError("Tried to send image but class did not have a send image delegate")
        }
        
        
        sendDelegate.sendImage(image: image)

    }
    
    @IBAction func savePressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Save to camera roll?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            //cancel
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            
            UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, false, 3.0)
            guard let context = UIGraphicsGetCurrentContext()else{
                fatalError("context was nil!")
            }
            self.contentView.layer.render(in: context)
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else{
                fatalError("Tried to create image from current graphics context but it returned nil!")
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: {
            
        })
        
    }
    
    @IBAction func brushSettingsPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: BrushSettingsSegueID, sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == BrushSettingsSegueID{
            let controller = segue.destination as! BrushSettingsViewController
            controller.delegate = self
            self.drawVCTransitionDelegate = controller
            controller.sliderInitialWidth = Float(self.contentView.drawWidth)
        }
    }
    @IBAction func undoPressed(_ sender: AnyObject) {
        self.contentView.undo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let delegate = self.scrollDelegate{
            delegate.zoomChanged(value: scrollView.zoomScale)
        }else{
            fatalError("scrolldelegate was nil!")
        }
        
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollViewBase
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        zooming = false
    }
    
    func scrollViewIsZooming() -> Bool {
        return zooming
    }
    
    //MARK: Transition Delegate
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        
        if let delegate = self.drawVCTransitionDelegate{
            delegate.didTransition(presentationStyle: presentationStyle)
        }
        
        if self.view.frame.width >= self.view.frame.height{
            updateButtonConstraints(presentationStyle: presentationStyle, portrait:false)
            
        }else{
            updateButtonConstraints(presentationStyle: presentationStyle, portrait:true)
            
        }
        
        updateButtonVisibility(presentationStyle: presentationStyle)
        
        
    }
    
    
    func colorChanged(color: CGColor) {
        self.contentView.changeColor(color: color)
        self.colorPickerButton.tintColor = UIColor(cgColor: color)
        
    }
    
    func widthChagned(width: CGFloat) {
        self.contentView.changeWidth(width: width)
    }
    
    func getPresenationStyle() -> MSMessagesAppPresentationStyle {
        guard let delegate = self.presentationStyleDelegate else{
            fatalError("Presenationstyledelegate was nil on DrawViewController")
        }
        return delegate.getPresentationStyle()
    }
    
}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double(M_PI * 2)
        rotation.duration = 2
        rotation.isCumulative = true
        rotation.repeatCount = FLT_MAX
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    
}
