//
//  BrushSettingsViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/17/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages

let BrushSettingsSegueID = "SettingsSegue"
let BrushSettingsFreeCell = "freeColorCell"
let BrushSettingsPremiumCell = "premiumColorCell"

protocol BrushSettingsDelegate{
    func colorChanged(color:CGColor)
    func widthChagned(width:CGFloat)
    
    func getPresenationStyle() -> MSMessagesAppPresentationStyle
}

class BrushSettingsViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StoreTableViewDelegate, TransitionDelegate {
    
    //i want to know when the presentiton style changes
    //i want to know what the initial style is by going delegate.presentaionstyle
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var widthSlider: UISlider!
    
    var brushSettingsTransitionDelegate:TransitionDelegate? = nil
    
    var colors:[UIColor] = []
    
    let defaultcolorpack = [#colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1),#colorLiteral(red: 0.2856909931, green: 0, blue: 0.9589199424, alpha: 1),#colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1),#colorLiteral(red: 0.9559464455, green: 0.7389599085, blue: 0.2778314948, alpha: 1),#colorLiteral(red: 0.5219543576, green: 0.7994346619, blue: 0.346042335, alpha: 1)]
    let bluecolorpack = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
    let redcolorpack = [#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)]
    let greencolorpack = [#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]

    
    let yellowcolorpack = [#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)]
    let shadesofgray = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1),#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)]
    
    //[#colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1),#colorLiteral(red: 0.2856909931, green: 0, blue: 0.9589199424, alpha: 1),#colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1),#colorLiteral(red: 0.9166661501, green: 0.4121252298, blue: 0.2839399874, alpha: 1),#colorLiteral(red: 0.9559464455, green: 0.7389599085, blue: 0.2778314948, alpha: 1),#colorLiteral(red: 0.5219543576, green: 0.7994346619, blue: 0.346042335, alpha: 1),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
    //,#colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1),#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1),#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1),#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)]
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
        
        if colors.count == 0{
            unlockPurchases()
        }
        
    }
    
    func didBecomeForeground(){
        
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
        return colors.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row >= 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrushSettingsFreeCell, for: indexPath)
            cell.backgroundColor = colors[indexPath.row - 1]
            cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.height) / 2.0
            return cell

        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storecell", for: indexPath)
            cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.height) / 2.0
            print("Created store cell")
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "storeSegue"{
            let destination = segue.destination as! StoreTableViewController
            destination.transactionDelegate = self
            self.brushSettingsTransitionDelegate = destination
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if (indexPath.row > 0){
            guard let delegate = self.delegate else{
                fatalError("delegate was nil for BrushSettingsViewController")
            }
            
            delegate.colorChanged(color: colors[indexPath.row - 1].cgColor)
            
            self.dismiss(animated: true, completion: {
            })

        }else{
            print("store")
        }
    }
    
    func didUpdateTransactions() {
        unlockPurchases()
        self.collectionView.reloadData()
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        if let delegate = brushSettingsTransitionDelegate{
            delegate.didTransition(presentationStyle: presentationStyle)
        }
    }
    
    func unlockPurchases(){
        let defaults = UserDefaults.standard
        
        colors = defaultcolorpack
        
        if defaults.bool(forKey: "com.skirkiles.pop.redcolors"){
            colors.append(contentsOf: redcolorpack)
        }
        
        if defaults.bool(forKey: "com.skirkiles.pop.bluecolors"){
            colors.append(contentsOf: bluecolorpack)
        }

        if defaults.bool(forKey: "com.skirkiles.pop.greencolors"){
            colors.append(contentsOf: greencolorpack)
        }

        self.collectionView.reloadData()
    }
    
    func getPresentationStyle() -> MSMessagesAppPresentationStyle {
        return self.delegate!.getPresenationStyle()
    }
@IBAction func widthChanged(_ sender: AnyObject) {
    delegate?.widthChagned(width: CGFloat(widthSlider.value))
}

}
