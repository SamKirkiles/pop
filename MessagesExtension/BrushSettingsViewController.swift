//
//  BrushSettingsViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/17/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

let BrushSettingsSegueID = "SettingsSegue"
let BrushSettingsFreeCell = "freeColorCell"
let BrushSettingsPremiumCell = "premiumColorCell"

protocol BrushSettingsDelegate{
    func colorChanged(color:CGColor)
    func widthChagned(width:CGFloat)
}

class BrushSettingsViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var widthSlider: UISlider!
    
    let colors:[UIColor] = [#colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1),#colorLiteral(red: 0.2856909931, green: 0, blue: 0.9589199424, alpha: 1),#colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1),#colorLiteral(red: 0.9166661501, green: 0.4121252298, blue: 0.2839399874, alpha: 1),#colorLiteral(red: 0.9559464455, green: 0.7389599085, blue: 0.2778314948, alpha: 1),#colorLiteral(red: 0.5219543576, green: 0.7994346619, blue: 0.346042335, alpha: 1),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1),#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1),#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]
    let colorDivider = 5
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
        if indexPath.row <= colorDivider{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrushSettingsFreeCell, for: indexPath)
            cell.backgroundColor = colors[indexPath.row]
            cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.height) / 2.0
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrushSettingsPremiumCell, for: indexPath)
            cell.backgroundColor = colors[indexPath.row]
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.height) / 2.0
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("This is the bool: ", UserDefaults.standard.bool(forKey: "com.skirkiles.pop.fullpalate"))
        
        guard let delegate = self.delegate else{
            fatalError("delegate was nil for BrushSettingsViewController")
        }
        if indexPath.row > self.colorDivider{
            if UserDefaults.standard.bool(forKey: "com.skirkiles.pop.fullpalate") == true{
                delegate.colorChanged(color: colors[indexPath.row].cgColor)
                self.dismiss(animated: true, completion: { 
                    
                })
            }else{
                let alertController = UIAlertController(title: "Buy All Colors", message: "You must buy the POP Full Color Palette to use this color.", preferredStyle: .alert)
                let purchaseAction = UIAlertAction(title: "Buy Now", style: .default, handler: { (action) in
                    if let product = IAPManager.sharedInstance.products.first{
                        IAPManager.sharedInstance.createPaymentRequestForProduct(product: product)
                    }
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    //canceled
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(purchaseAction)
                
                self.present(alertController, animated: true, completion: {
                    8
                })
            }
        }else{
            delegate.colorChanged(color: colors[indexPath.row].cgColor)
            self.dismiss(animated: true, completion: { 
                
            })
        }
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
