//
//  MainMessagesViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/14/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages
import StoreKit
import CloudKit

protocol TransitionDelegate{
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle)
}

protocol SelectedImageDelegate{
    func conversationWillSelectImage()
    func conversationDidSelectImage(image:UIImage)
    func conversationImageError()
    func conversationSaveError(error:Error)
    func conversationBeganSaving()
    func conversationEndedSaving()
}

class MainMessagesViewController: MSMessagesAppViewController,SelectPhotoDelegate , PresentationStyleDelegate{
    
    var delegate:TransitionDelegate? = nil
    var selectedImageDelegate:SelectedImageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SKPaymentQueue.canMakePayments(){
            IAPManager.sharedInstance.setupInAppPurchases()
        }
        
        
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        presentViewcontroller(for: conversation, with: presentationStyle)
        self.checkForSelectedMessage(convo: conversation)
        
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        self.checkForSelectedMessage(convo: conversation)
        print("Did select has been called")
    }
    
    
    
    func checkForSelectedMessage(convo: MSConversation){
        if let message = convo.selectedMessage{
            
            guard let url = message.url else {
                fatalError("id was nil")
            }
            
            let name = "\(url)"
            
            guard let delegate = self.selectedImageDelegate else{
                print("Delegate was not assigned")
                return
            }
            delegate.conversationWillSelectImage()
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            let recordID = CKRecordID(recordName: name)
            
            let operation = CKFetchRecordsOperation(recordIDs: [recordID])
            operation.qualityOfService = .userInteractive
            operation.database = publicDB
            operation.fetchRecordsCompletionBlock = {recordDictionary, error in
                guard let records = recordDictionary else {
                    print("Could not load records")
                    delegate.conversationImageError()
                    return
                }
                
                guard let record = records[recordID]else{
                    print("Could not load record")
                    delegate.conversationImageError()
                    return
                }
                
                guard let asset = record["Image"] as? CKAsset else{
                    print("Invalid Image")
                    delegate.conversationImageError()
                    return
                }
                
                DispatchQueue.global().async {
                do{
                    let imageData = try Data(contentsOf: asset.fileURL)
                    let image = UIImage(data: imageData)
                    delegate.conversationDidSelectImage(image: image!)
                }catch{
                    print("Error with image")
                    return
                }
                }
                
            }
            
            publicDB.add(operation)
            
        }else{
            print("no selected message")
        }
        
    }
    
    private func presentViewcontroller(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle){
        guard let controller: SelectPhotoCollectionViewController = storyboard?.instantiateViewController(withIdentifier: SelectPhotoCollectionViewIdentifier) as? SelectPhotoCollectionViewController else{
            fatalError("Unable to instantiate a SelectPhotoCollectionViewController")
        }
        
        controller.delegate = self
        self.delegate = controller
        self.selectedImageDelegate = controller
        controller.presentationStyleDelegate = self
        
        for child in childViewControllers{
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
        
        guard let delegate = self.delegate else{
            fatalError("transition delegate was nil!")
        }
        
        delegate.didTransition(presentationStyle: presentationStyle)
    }
    
    func getPresentationStyle() -> MSMessagesAppPresentationStyle {
        return self.presentationStyle
    }
    
    func requestStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        self.requestPresentationStyle(presentationStyle)
    }
    
    
    //MARK: - Sending Photo
    
    func sendPhoto(photo: UIImage) {
        
        let layout = MSMessageTemplateLayout()
        layout.image = photo
        
        let message = MSMessage()
        message.layout = layout
        
        let publicDB = CKContainer.default().publicCloudDatabase
        let imageRecord = CKRecord(recordType: "Pictures")
        imageRecord["Image"] = CKAsset(fileURL: writeImage(image: photo))
        let code = imageRecord.recordID.recordName
        guard let delegate = self.selectedImageDelegate else{
            fatalError("Could not access delegate")
        }
        delegate.conversationBeganSaving()
        
        publicDB.save(imageRecord) { (record, error) in
            if error != nil{
                    delegate.conversationSaveError(error: error!)
                    delegate.conversationEndedSaving()
                    return
            }else{
                let url = URL(string: code)
                
                message.url = url
                delegate.conversationEndedSaving()

                self.activeConversation?.insert(message, completionHandler: { (error) in
                    print(error?.localizedDescription)
                    self.requestPresentationStyle(.compact)
                })

            }
        }

        
        
    }
    
    func writeImage(image:UIImage) -> URL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(NSUUID().uuidString + ".png")
        if let imageData = UIImagePNGRepresentation(image){
            try! imageData.write(to: fileURL, options: .atomic)
        }
        return fileURL
    }
    
}

