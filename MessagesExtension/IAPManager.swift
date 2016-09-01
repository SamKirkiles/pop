//
//  IAPManager.swift
//  pop
//
//  Created by Sam Kirkiles on 8/30/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import StoreKit

let ProductIdentifiers: [String] = ["com.skirkiles.pop.fullpalate"]

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    static let sharedInstance = IAPManager()
    var request:SKProductsRequest!
    var products:[SKProduct] = []
    
    func setupInAppPurchases(){
        self.validateProductIdentifiers(identifiers: ProductIdentifiers)
        SKPaymentQueue.default().add(self)
    }
    
    func validateProductIdentifiers(identifiers:[String]){
        let productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        self.request = productRequest
        productRequest.delegate = self
        productRequest.start()
        
    }
    
    func createPaymentRequestForProduct(product:SKProduct){
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    func unlockPurchasedFunctionalityForProductIdentifier(productIdentifier:String){
        
        UserDefaults.standard.set(true, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
        
    }
    
    //MARK: SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState{
            case.purchasing:
                print("Purchasing")
                
            case.deferred:
                print("Deferred")
                
            case.failed:
                print("Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            case.purchased:
                print("Purchased")
                unlockPurchasedFunctionalityForProductIdentifier(productIdentifier: transaction.payment.productIdentifier)
            case.restored:
                print("Restored")
                
            }
        }

    }
    
    //MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //
        self.products = response.products
        for product in self.products{
            print(product.localizedTitle, product.localizedDescription)
        }

    }

}
