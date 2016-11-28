//
//  StoreTableViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 10/27/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import StoreKit
import Messages

protocol StoreTableViewDelegate {
    func getPresentationStyle() -> MSMessagesAppPresentationStyle
}

enum CellPurchaseState {
    case buy
    case purchased
    case loading
}

class StoreTableViewController: UITableViewController, TransitionDelegate {
    
    
    var transactionInProgress = false
    
    var transactionDelegate:StoreTableViewDelegate? = nil
    
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        print("Now restore purchases")
        
        let alert = UIAlertController(title: "Restore Purchases", message: "Restore previously purchased color packs?", preferredStyle: .alert)
        let acceptButton = UIAlertAction(title: "Restore", style: .default) { (action) in
            if (SKPaymentQueue.canMakePayments()) {
                SKPaymentQueue.default().restoreCompletedTransactions()
            }
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //cancel buttion
        }
        alert.addAction(cancelButton)
        alert.addAction(acceptButton)
        self.present(alert, animated: true) {
            //completion
        }
    }
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true) {
            //dismiss
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTableViewInsets(preferredSize: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StoreTableViewController.IAPManagerDidUpdate), name: IAPManagerDidUpdateNotification, object: nil)
    }
    
    func IAPManagerDidUpdate(){
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return IAPManager.sharedInstance.products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! StoreTableViewCell
        
        cell.purchaseButton.layer.borderColor = cell.purchaseButton.tintColor.cgColor
        cell.purchaseButton.layer.borderWidth = 2
        cell.purchaseButton.layer.cornerRadius = 5.0
        cell.purchaseButton.tag = indexPath.row
        
        cell.purchaseTitleLabel.text = IAPManager.sharedInstance.products[indexPath.row].localizedTitle
        
        switch IAPManager.sharedInstance.products[indexPath.row].productIdentifier {
        case "com.skirkiles.pop.bluecolors":
            cell.productID = "com.skirkiles.pop.bluecolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Blue Color Pack")
        case "com.skirkiles.pop.redcolors":
            cell.productID = "com.skirkiles.pop.redcolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Red Color Pack")
        case "com.skirkiles.pop.greencolors":
            cell.productID = "com.skirkiles.pop.greencolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Green Color Pack")
        case "com.skirkiles.pop.graycolors":
            cell.productID = "com.skirkiles.pop.graycolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Gray Color Pack")
        case "com.skirkiles.pop.purplecolors":
            cell.productID = "com.skirkiles.pop.purplecolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Purple Color Pack")
        case "com.skirkiles.pop.yellowcolors":
            cell.productID = "com.skirkiles.pop.purplecolors"
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Yellow Color Pack")
        default:
            print("No Image to display!")
        }
        
        let defaults = UserDefaults.standard
        //if the item has been bought before
        if defaults.bool(forKey: IAPManager.sharedInstance.products[indexPath.row].productIdentifier){
            cell.setState(state: .purchased)
        }else{
            cell.setState(state: .buy)
        }
        
        cell.purchaseButton.addTarget(self, action: #selector(StoreTableViewController.purchaseButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func purchaseButtonPressed(sender: UIButton){
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! StoreTableViewCell
        cell.setState(state: .loading)

        
        IAPManager.sharedInstance.createPaymentRequestForProduct(product: IAPManager.sharedInstance.products[sender.tag])
        self.transactionInProgress = true
        
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func cellForProductID(productId:String) -> StoreTableViewCell?{
        var i = 0
        for product in IAPManager.sharedInstance.products{
            print(i)
            if productId == product.productIdentifier{
                let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! StoreTableViewCell
                print(cell.productID)
                return cell
            }
            i += 1
        }
        return nil
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        print(presentationStyle.rawValue)
        self.updateTableViewInsets(preferredSize: nil)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateTableViewInsets(preferredSize: size)
    }
    
    func updateTableViewInsets(preferredSize: CGSize?){
        // set the height of the table view
        
        guard let delegate = self.transactionDelegate else {
            fatalError("Transition delegate not assigned!")
        }
        
        var size:CGSize
        
        if  preferredSize != nil{
            size = preferredSize!
        }else{
            size = self.view.frame.size
        }
                
        self.tableView?.contentInset = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        self.tableView?.scrollIndicatorInsets = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        
        self.tableView?.setContentOffset(CGPoint(x: 0, y: -LayoutManager.getTopInsetAmount(size: size, style: delegate.getPresentationStyle())), animated: true)

    
    }
}
