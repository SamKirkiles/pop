//
//  IAPManager.swift
//  pop
//
//  Created by Sam Kirkiles on 11/28/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPManagerDelegate {
    func updatedTransactions()
}

let IAPManagerDidUpdateNotification = Notification.Name("IAPManagerDidUpdateNotification")

class IAPManager : NSObject, SKProductsRequestDelegate , SKPaymentTransactionObserver{
    
    let productIDs:Array<String> = ["com.skirkiles.pop.bluecolors","com.skirkiles.pop.redcolors","com.skirkiles.pop.greencolors","com.skirkiles.pop.graycolors","com.skirkiles.pop.purplecolors","com.skirkiles.pop.yellowcolors"]

    var products:[SKProduct]!
    
    static let sharedInstance = IAPManager()
    
    func setupInAppPurchases(){
        //the first thing to be called This will give the request the product ids we need to know about and will call the delegate method after start is called
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
        
        SKPaymentQueue.default().add(self)
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //recieved response
        self.products = response.products
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        

        for transaction in transactions{
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased, .restored:
                print("Purchase or Restore successfully completed")
                //unlock functionality here
                unlockContentForProductID(productID: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                print("Transaction Failed!")
                print(transaction.error?.localizedDescription)
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.purchasing:
                print("Purchasing!")
            case SKPaymentTransactionState.deferred:
                print("Deferred")
            }
        }
        
        NotificationCenter.default.post(name: IAPManagerDidUpdateNotification, object: self)

    }
    
    func unlockContentForProductID(productID:String){
        UserDefaults.standard.set(true, forKey: productID)
        UserDefaults.standard.synchronize()
    }
    
    func createPaymentRequestForProduct(product:SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}
