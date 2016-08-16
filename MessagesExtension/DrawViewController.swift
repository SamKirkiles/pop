//
//  DrawViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

let DrawViewControllerSegueID = "DrawVCSegueID"
let DrawViewControllerStoryboardID = "DrawViewControllerID"

class DrawViewController: UIViewController, UIScrollViewDelegate {

    //IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: ContentView!
    
    //Properties
    var image:UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        
        guard let image = self.image else {
            fatalError("Image was nil on Draw View Controller")
        }
        self.contentView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }

}
