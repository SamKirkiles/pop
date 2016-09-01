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
    
    override func didBecomeActive(with conversation: MSConversation) {
        if let message = conversation.selectedMessage{
            //get the message url
            if let url = message.url{
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false){
                    for item in components.queryItems!{
                        if item.name == "image"{
                            guard let data = Data.init(base64Encoded: item.value!) else{
                                fatalError("data was nil")
                            }
                            let image = UIImage(data: data)
                            print(image)
                        }
                    }
                }
            }
        }
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
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        presentViewcontroller(for: conversation, with: presentationStyle)
        
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        // Use this method to prepare for the change in presentation style.
        
    }
    
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
    
    
    // MARK: - Delegate
    
    func sendPhoto(photo: UIImage) {
        
        let layout = MSMessageTemplateLayout()
        layout.image = photo
        
        let message = MSMessage()
        message.layout = layout
        
        var components = URLComponents()
        
        guard let data = UIImagePNGRepresentation(photo) else{
            fatalError("could not write image to data")
        }
        
        let dataString = data.base64EncodedString()
        
        components.queryItems?.append(URLQueryItem(name: "image", value: dataString))
        
        if let url = components.url{
            message.url = url
            
        }else{
            fatalError("could not write to url")
        }
        
        self.activeConversation?.insert(message, completionHandler: { (error) in
            print(error)
        })
        
    }
}
