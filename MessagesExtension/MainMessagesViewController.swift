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

protocol MessageDelegate{
    func didSelectImage(message:MSMessage, convo:MSConversation)
}

class MainMessagesViewController: MSMessagesAppViewController,SelectPhotoDelegate , PresentationStyleDelegate{
    
    var delegate:TransitionDelegate? = nil
    var messageDelegate:MessageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SKPaymentQueue.canMakePayments(){
            IAPManager.sharedInstance.setupInAppPurchases()
        }
        
        
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        if let message = conversation.selectedMessage{
            
            guard let url = message.url else {
                fatalError("id was nil")
            }
            
            let name = "\(url)"
            
            
            let publicDB = CKContainer.default().publicCloudDatabase
            let recordID = CKRecordID(recordName: name)
            publicDB.fetch(withRecordID: recordID) { (result, error) in
                
                guard let record = result else{
                    print("error retreiving record ", error?.localizedDescription)
                    return
                }
                
                guard let asset = record["Image"] as? CKAsset else{
                    print("Invalid Image")
                    return
                }
                
                do{
                    let imageData = try Data(contentsOf: asset.fileURL)
                    let image = UIImage(data: imageData)
                    print(image)

                }catch{
                    print("Error with image")
                    return
                }
                

                
            }
            
        }else{
            print("no selected message")
        }

        
        presentViewcontroller(for: conversation, with: presentationStyle)
        
    }

    private func presentViewcontroller(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle){
        guard let controller: SelectPhotoCollectionViewController = storyboard?.instantiateViewController(withIdentifier: SelectPhotoCollectionViewIdentifier) as? SelectPhotoCollectionViewController else{
            fatalError("Unable to instantiate a SelectPhotoCollectionViewController")
        }
        
        controller.delegate = self
        self.delegate = controller
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
    
    
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        if let delegate = self.messageDelegate{
            delegate.didSelectImage(message: message, convo: conversation)
        }
        
        print("did select message")
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
        
        message.url = URL(string: uploadToCloud(image: photo))
        
        self.activeConversation?.insert(message, completionHandler: { (error) in
            print(error?.localizedDescription)
        })
        
    }
    
    func uploadToCloud(image:UIImage) -> String{
        let publicDB = CKContainer.default().publicCloudDatabase
        let imageRecord = CKRecord(recordType: "Pictures")
        imageRecord["Image"] = CKAsset(fileURL: writeImage(image: image))
        
        publicDB.save(imageRecord) { (record, error) in
            print(error?.localizedDescription)
        }
        
        return imageRecord.recordID.recordName
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

