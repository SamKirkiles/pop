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

enum CellPurchaseState {
    case buy
    case purchased
    case loading
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
        productIDs.append("com.skirkiles.pop.graycolors")
        productIDs.append("com.skirkiles.pop.purplecolors")
        productIDs.append("com.skirkiles.pop.yellowcolors")
        requestProductInfo()
        
        SKPaymentQueue.default().add(self)
        
        print("Added to default queue")
        
        //set the insets for the initila view
        updateTableViewInsets(preferredSize: nil)
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
        if defaults.bool(forKey: productsArray[indexPath.row].productIdentifier){
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

        
        let payment = SKPayment(product: productsArray[sender.tag])
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
        
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
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
                transactionInProgress = false
                if let cell:StoreTableViewCell = cellForProductID(productId: transaction.payment.productIdentifier){
                    cell.setState(state: .buy)
                }

                
            case SKPaymentTransactionState.purchasing:
                
                //purchasing set the correct cell to loading
                print("Purchasing!")
                
                if let cell:StoreTableViewCell = cellForProductID(productId: transaction.payment.productIdentifier){
                    cell.setState(state: .loading)
                }
                
            case SKPaymentTransactionState.deferred:
                
                //deferred
                print("Deferred")
            }
        }
    }
    
    func cellForProductID(productId:String) -> StoreTableViewCell?{
        var i = 0
        for product in productsArray{
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
        
        print("The size is: ",size)
        
        self.tableView?.contentInset = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        self.tableView?.scrollIndicatorInsets = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        
        self.tableView?.setContentOffset(CGPoint(x: 0, y: -LayoutManager.getTopInsetAmount(size: size, style: delegate.getPresentationStyle())), animated: true)

    
    }
}
