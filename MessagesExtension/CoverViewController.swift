//
//  CoverViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/17/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

let CoverVCStoryboardID = "coverID"
let CoverVCSegue = "coverSegue"

class CoverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width < size.height {
            self.dismiss(animated: false, completion: nil)
        }
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
