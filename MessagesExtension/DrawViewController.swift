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
    //Properties
    var image:UIImage?
    
    
    //Buttons
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    //Misc
    
    var zooming = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        self.scrollView.delaysContentTouches = false
        
        
        guard let image = self.image else {
            fatalError("Image was nil on Draw View Controller")
        }
        self.contentView.image = image
        self.scrollDelegate = self.contentView
    }
    
    //View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.colorPickerButton.tintColor = UIColor(cgColor: self.contentView.drawColor)
        
        guard let delegate = self.presentationStyleDelegate else{
            fatalError("Presenationstyle delegate was nil on drawviewcontroller")
        }
        self.updateButtonConstraints(presentationStyle: delegate.getPresentationStyle())
        
        self.contentView.zoomDelegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        self.updateConstraints()
    }
    
    func rotated(){

        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            self.updateConstraints()
            
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            self.updateConstraints()
            
        }
    }
    
    
    func updateConstraints(){
        guard let image = self.image else {
            fatalError("Image was nil in DrawViewController when calling UpdateConstraints!")
        }
        
        
        
        
        // if the width is greater than the height
        if image.size.width>image.size.height{
            
            if self.view.frame.height >= self.view.frame.width{
                contentViewTopConstraint.constant = (self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2
                contentViewBottomConstraint.constant = (self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2
                contentViewRightConstraint.constant = 0
                contentViewLeftConstraint.constant = 0
                self.contentView.setNeedsDisplay()


                
            }else{
                contentViewTopConstraint.constant = 0
                contentViewBottomConstraint.constant = 0
                contentViewRightConstraint.constant = (self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2
                contentViewLeftConstraint.constant = (self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2
                self.contentView.setNeedsDisplay()

            }
        }else if image.size.width<image.size.height{
            if self.view.frame.height >= self.view.frame.width{
                contentViewBottomConstraint.constant = (self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2
                contentViewTopConstraint.constant = (self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2
                contentViewRightConstraint.constant = 0
                contentViewLeftConstraint.constant = 0
                self.contentView.setNeedsDisplay()

            }else{
                contentViewBottomConstraint.constant = 0
                contentViewTopConstraint.constant = 0
                contentViewRightConstraint.constant = (self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2
                contentViewLeftConstraint.constant = (self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2
                self.contentView.setNeedsDisplay()

            }

        }else{
            if self.view.frame.height >= self.view.frame.width{
                contentViewTopConstraint.constant = (self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2
                contentViewBottomConstraint.constant = ((self.view.frame.height - (self.view.frame.width * image.size.height)/image.size.width)/2)
                contentViewRightConstraint.constant = 0
                contentViewLeftConstraint.constant = 0
                self.contentView.setNeedsDisplay()

            }else{
                contentViewTopConstraint.constant = 0
                contentViewBottomConstraint.constant = 0
                contentViewRightConstraint.constant = ((self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2)
                contentViewLeftConstraint.constant = (self.view.frame.width - (self.view.frame.height * image.size.width)/image.size.height)/2
                
                self.contentView.setNeedsDisplay()


            }
        }
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)

        
    }
    
    func updateButtonConstraints(presentationStyle: MSMessagesAppPresentationStyle){
        if presentationStyle == .compact{
            self.closeButtonTopConstraint.constant = 0
            self.sendButtonTopConstraint.constant = 0
        }else{
            self.closeButtonTopConstraint.constant = 80
            self.sendButtonTopConstraint.constant = 80
        }
    }
    
    //MARK: UIButtons
    
    @IBAction func closePressed(_ sender: AnyObject) {
        guard let sendDelegate = self.sendImageDelegate else {
            fatalError("Tried to send image but class did not have a send image delegate")
        }
        
        sendDelegate.requestStyle(style: .compact)
        
        self.dismiss(animated: true, completion: {
            //completion
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
        
        sendDelegate.requestStyle(style: .compact)
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
        updateButtonConstraints(presentationStyle: presentationStyle)
        
        if presentationStyle == .compact{
            self.contentView.isUserInteractionEnabled = false
            self.colorPickerButton.isHidden = true
            self.buttonOutline.isHidden = true
            self.undoButton.isHidden = true
        }else{
            self.contentView.isUserInteractionEnabled = true
            self.colorPickerButton.isHidden = false
            self.buttonOutline.isHidden = false
            self.undoButton.isHidden = false
        }
        
    }
    
    
    func colorChanged(color: CGColor) {
        self.contentView.changeColor(color: color)
        self.colorPickerButton.tintColor = UIColor(cgColor: color)
    }
    
    func widthChagned(width: CGFloat) {
        self.contentView.changeWidth(width: width)
    }
    
}
