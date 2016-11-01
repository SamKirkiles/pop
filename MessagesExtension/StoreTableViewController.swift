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
    func didUpdateTransactions()
    func getPresentationStyle() -> MSMessagesAppPresentationStyle
}

class StoreTableViewController: UITableViewController, SKProductsRequestDelegate,SKPaymentTransactionObserver, TransitionDelegate {
    
    var productIDs:Array<String> = []
    var productsArray: Array<SKProduct> = []
    
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
        
        productIDs.append("com.skirkiles.pop.bluecolors")
        productIDs.append("com.skirkiles.pop.redcolors")
        productIDs.append("com.skirkiles.pop.greencolors")
        requestProductInfo()
        
        SKPaymentQueue.default().add(self)
        
        //set the insets for the initila view
        guard let delegate = self.transactionDelegate else{
            fatalError("Delegate not assigned to Store tableview controller")
        }

        if self.view.frame.size.height > self.view.frame.size.width {
            //we are now in landscape
            if delegate.getPresentationStyle() == .compact{
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }else{
                self.tableView.contentInset = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
            }
            
        } else {
            // we are now in portrait
            if delegate.getPresentationStyle() == .compact{
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }else{
                self.tableView.contentInset = UIEdgeInsets(top: 66, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 66, left: 0, bottom: 50, right: 0)
            }
        }
        
    }
    
    func requestProductInfo(){
        if SKPaymentQueue.canMakePayments(){
            let productRequest = SKProductsRequest(productIdentifiers: Set(productIDs))
            productRequest.delegate = self
            productRequest.start()
        }else{
            print("Cannot make payments!")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0{
            for product in response.products{
                self.productsArray.append(product)
            }
            self.tableView.reloadData()
        }else{
            print("There are no products")
        }
        
        if response.invalidProductIdentifiers.count >= 0{
            print(response.invalidProductIdentifiers.description)
        }
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
        return productsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! StoreTableViewCell
        
        cell.purchaseButton.layer.borderColor = cell.purchaseButton.tintColor.cgColor
        cell.purchaseButton.layer.borderWidth = 2
        cell.purchaseButton.layer.cornerRadius = 5.0
        cell.purchaseButton.tag = indexPath.row
        
        cell.purchaseTitleLabel.text = productsArray[indexPath.row].localizedTitle
        
        switch productsArray[indexPath.row].productIdentifier {
        case "com.skirkiles.pop.bluecolors":
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Blue Color Pack")
        case "com.skirkiles.pop.redcolors":
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Red Color Pack")
        case "com.skirkiles.pop.greencolors":
            cell.purchaseImageView.image = #imageLiteral(resourceName: "Green Color Pack")
        default:
            print("No Image to display!")
        }
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: productsArray[indexPath.row].productIdentifier){
            cell.purchaseButton.isHidden = true
            cell.purchasedLabel.isHidden = false
        }else{
            cell.purchaseButton.isHidden = false
            cell.purchasedLabel.isHidden = true
        }
        
        cell.purchaseButton.addTarget(self, action: #selector(StoreTableViewController.purchaseButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func purchaseButtonPressed(sender: UIButton){
        let payment = SKPayment(product: productsArray[sender.tag])
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased, .restored:
                print("Purchase or Restore successfully completed")
                transactionInProgress = false
                unlockContentForTransaction(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                self.tableView.reloadData()
            case SKPaymentTransactionState.failed:
                print("Transaction Failed!")
                print(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        print(presentationStyle.rawValue)
        if presentationStyle == .compact{
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if self.view.frame.size.height > self.view.frame.size.width {
            //we are now in landscape
            guard let delegate = self.transactionDelegate else{
                fatalError("Delegate not assigned to Store tableview controller")
            }
            
            
            if delegate.getPresentationStyle() == .compact{
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }else{
                self.tableView.contentInset = UIEdgeInsets(top: 66, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 66, left: 0, bottom: 50, right: 0)
            }
            
        } else {
            // we are now in portrait
            guard let delegate = self.transactionDelegate else{
                fatalError("Delegate not assigned to Store tableview controller")
            }
            
            if delegate.getPresentationStyle() == .compact{
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }else{
                self.tableView.contentInset = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 86, left: 0, bottom: 50, right: 0)
            }
            
        }
        
    }
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]){
        guard let delegate = self.transactionDelegate else{
            fatalError("Delegate not assigned")
        }
        delegate.didUpdateTransactions()
        
        SKPaymentQueue.default().remove(self)
    }
    
    func unlockContentForTransaction(transaction:SKPaymentTransaction){
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: transaction.payment.productIdentifier)
        defaults.synchronize()
        
    }
    
}
