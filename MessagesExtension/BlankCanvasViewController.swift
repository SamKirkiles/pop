//
//  BlankCanvasViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 9/27/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages

protocol BlankCanvasDelegate {

    func didChooseBlankCanvas(type: BlankCanvasType)
}

enum BlankCanvasType {
    case square
    case portrait
    case landscape
}


class BlankCanvasViewController: UIViewController, TransitionDelegate {
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var segementedControl: UISegmentedControl!
    
    var transitionDelegate:TransitionDelegate? = nil
    
    var delegate:BlankCanvasDelegate? = nil
    

    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blurView.alpha = 0.0
        
        self.mainView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            
            self.blurView.alpha = 1.0
        }
        
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurView.alpha = 0.0
            
        }) { (finished) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createPressed(_ sender: AnyObject) {
        
        guard let delegate = self.delegate else{
            fatalError("Delegate not assigned for create pressed on blank canavs")
        }
        
        switch segementedControl.selectedSegmentIndex {
        case 0:
            delegate.didChooseBlankCanvas(type: .square)
        case 1:
            delegate.didChooseBlankCanvas(type: .portrait)
        case 2:
            delegate.didChooseBlankCanvas(type: .landscape)
        default:
            delegate.didChooseBlankCanvas(type: .square)
        }
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .compact{
            //compact mode
            backgroundTopConstraint.constant = 0
        }else{
            //expanded
            backgroundTopConstraint.constant = 66 + 20
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
