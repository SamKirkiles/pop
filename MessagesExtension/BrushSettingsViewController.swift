//
//  BrushSettingsViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/17/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

let BrushSettingsSegueID = "SettingsSegue"
let BrushSettingsCellID = "ColorCell"

protocol BrushSettingsDelegate{
    func colorChanged(color:CGColor)
    func widthChagned(width:CGFloat)
}

class BrushSettingsViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var widthSlider: UISlider!
    
    let colors:[UIColor] = [#colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1), #colorLiteral(red: 0.2856909931, green: 0, blue: 0.9589199424, alpha: 1), #colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1), #colorLiteral(red: 0.9166661501, green: 0.4121252298, blue: 0.2839399874, alpha: 1), #colorLiteral(red: 0.9559464455, green: 0.7389599085, blue: 0.2778314948, alpha: 1), #colorLiteral(red: 0.5219543576, green: 0.7994346619, blue: 0.346042335, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)]

    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var delegate:BrushSettingsDelegate? = nil
    
    
    var sliderInitialWidth:Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurView.layer.cornerRadius = 10
        self.blurView.layer.masksToBounds = true
        
        tapGestureRecognizer.delegate = self
        
        self.widthSlider.value = sliderInitialWidth

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Gesture recognizer methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view{
            self.dismiss(animated: true, completion: {
                
            })
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view{
            self.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view{
            return true
        }else {
            return false
        }
    }
    
    // MARK: Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrushSettingsCellID, for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.height) / 2.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else{
            fatalError("delegate was nil for BrushSettingsViewController")
        }
        delegate.colorChanged(color: colors[indexPath.row].cgColor)

    }

    @IBAction func widthChanged(_ sender: AnyObject) {
        delegate?.widthChagned(width: CGFloat(widthSlider.value))
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
