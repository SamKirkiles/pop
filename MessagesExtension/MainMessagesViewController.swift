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
    func conversationProgressUpdated(progress:Double)
}

class MainMessagesViewController: MSMessagesAppViewController,SelectPhotoDelegate , PresentationStyleDelegate{
    
    var delegate:TransitionDelegate? = nil
    var selectedImageDelegate:SelectedImageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        print("Size: ", self.view.frame.size)
        
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
    }
    
    
    
    func checkForSelectedMessage(convo: MSConversation){
        if let message = convo.selectedMessage{
            
            guard let url = message.url else {
                fatalError("id was nil")
            }
            
            let name = "\(url)"
            
            guard let delegate = self.selectedImageDelegate else{
                return
            }
            delegate.conversationWillSelectImage()
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            let recordID = CKRecordID(recordName: name)
            
            let operation = CKFetchRecordsOperation(recordIDs: [recordID])
            operation.qualityOfService = .userInteractive
            operation.database = publicDB
            operation.fetchRecordsCompletionBlock = {recordDictionary, error in
                
                if let error = error{
                    print( error.localizedDescription)
                }
                guard let records = recordDictionary else {
                    delegate.conversationImageError()
                    return
                }
                
                guard let record = records[recordID]else{
                    delegate.conversationImageError()
                    return
                }
                
                guard let asset = record["Image"] as? CKAsset else{
                    delegate.conversationImageError()
                    return
                }
                
                DispatchQueue.main.async {
                    do{
                        let imageData = try Data(contentsOf: asset.fileURL)
                        let image = UIImage(data: imageData)
                        delegate.conversationDidSelectImage(image: image!)
                    }catch{
                        return
                    }
                }
                                
            }
            
            publicDB.add(operation)
            
        }else{
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
        if self.presentedViewController == nil{
            self.present(controller, animated: false) {
                print("Child View Controllers Count", self.childViewControllers.count)
            }
        }
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
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: [imageRecord], recordIDsToDelete: nil)
        
        saveOperation.perRecordProgressBlock = {record, progress in
            delegate.conversationProgressUpdated(progress: progress)
        }
        
        saveOperation.modifyRecordsCompletionBlock = { records, deletedRecordIDs, error in
            if error != nil{
                delegate.conversationSaveError(error: error!)
                delegate.conversationEndedSaving()
                return
            }else{
                let url = URL(string: code)
                
                message.url = url
                delegate.conversationEndedSaving()
                
                self.activeConversation?.insert(message, completionHandler: { (error) in
                    self.requestPresentationStyle(.compact)
                })
                
            }
        }
        saveOperation.qualityOfService = .userInteractive
        saveOperation.isAtomic = false
        saveOperation.savePolicy = .changedKeys
        publicDB.add(saveOperation)
        
        
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

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}


